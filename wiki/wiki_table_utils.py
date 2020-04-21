import codecs
import csv
from builtins import range

from fonduer.candidates.models import Candidate
from fonduer.parser.models import Document, Sentence
from fonduer.learning.utils import confusion_matrix
from fonduer.supervision.models import GoldLabel, GoldLabelKey

try:
    from IPython import get_ipython

    if "IPKernelApp" not in get_ipython().config:
        raise ImportError("console")
except (AttributeError, ImportError):
    from tqdm import tqdm
else:
    from tqdm import tqdm_notebook as tqdm


# Define labels
ABSTAIN = -1
FALSE = 0
TRUE = 1


def get_gold_dict(
    filename, doc_on=True, presidentname_on=True, placeofbirth_on=True, docs=None
):
    with codecs.open(filename) as csvfile:
        gold_reader = csv.reader(csvfile, delimiter=";")
        # skip header row
        next(gold_reader)
        gold_dict = set()
        for row in gold_reader:
            (doc, presidentname, placeofbirth) = row
            docname_without_spaces = doc.replace(" ", "_")
            if docs is None or docname_without_spaces.upper() in docs:
                if not (doc and placeofbirth and presidentname):
                    continue
                else:
                    key = []
                    if doc_on:
                        key.append(docname_without_spaces.upper())
                    if presidentname_on:
                        key.append(presidentname.upper())
                    if placeofbirth_on:
                        key.append(placeofbirth.upper())
                    gold_dict.add(tuple(key))
    return gold_dict


gold_dict = get_gold_dict("data/president_tutorial_gold.csv")


def gold(c: Candidate) -> int:
    doc = (c[0].context.sentence.document.name).upper()
    president_name = (c[0].context.get_span()).upper()
    birthplace = (c[1].context.get_span()).upper()

    cand_tuple = (doc, president_name, birthplace)
    # gold_matches = [x for x in gold_dict if x[0] == doc]
    if cand_tuple in gold_dict:
        return TRUE
    else:
        return FALSE


def entity_level_f1(candidates, gold_file, corpus=None):
    """Checks entity-level recall of candidates compared to gold.

    Turns a CandidateSet into a normal set of entity-level tuples
    (doc, president_name, birthplace)
    then compares this to the entity-level tuples found in the gold.

    Example Usage:
        from hardware_utils import entity_level_total_recall
        candidates = # CandidateSet of all candidates you want to consider
        gold_file = 'tutorials/tables/data/hardware/hardware_gold.csv'
        entity_level_total_recall(candidates, gold_file, 'stg_temp_min')
    """
    docs = [(doc.name).upper() for doc in corpus] if corpus else None
    gold_set = get_gold_dict(gold_file, docs=docs)
    if len(gold_set) == 0:
        print("Gold File: {gold_file}")
        print("Gold set is empty.")
        return
    # Turn CandidateSet into set of tuples
    print("Preparing candidates...")
    entities = set()
    for i, c in enumerate(tqdm(candidates)):
        doc = c[0].context.sentence.document.name.upper()
        president_name = c[0].context.get_span().upper()
        birthplace = c[1].context.get_span().upper()
        entities.add((doc, president_name, birthplace))

    (TP_set, FP_set, FN_set) = confusion_matrix(entities, gold_set)
    TP = len(TP_set)
    FP = len(FP_set)
    FN = len(FN_set)

    prec = TP / (TP + FP) if TP + FP > 0 else float("nan")
    rec = TP / (TP + FN) if TP + FN > 0 else float("nan")
    f1 = 2 * (prec * rec) / (prec + rec) if prec + rec > 0 else float("nan")
    print("========================================")
    print("Scoring on Entity-Level Gold Data")
    print("========================================")
    print(f"Corpus Precision {prec:.3}")
    print(f"Corpus Recall    {rec:.3}")
    print(f"Corpus F1        {f1:.3}")
    print("----------------------------------------")
    print(f"TP: {TP} | FP: {FP} | FN: {FN}")
    print("========================================\n")
    return [sorted(list(x)) for x in [TP_set, FP_set, FN_set]]
