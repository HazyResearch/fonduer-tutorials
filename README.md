# Fonduer Tutorials

## Hardware Tutorial

In this tutorial, we build a `Fonduer` application to tackle the task of
extracting maximum storage temperatures for specific transistor part numbers
from their datasheets.

### Hardware Figures Tutorial

In this tutorial, we build a `Fonduer` application to tackle the task of
extracting images for specific transistors from their datasheets. This
demonstrates how `Fonuder` can be used for image data in additional to text.

### Paleo Tutorial

In this tutorial, we will build a `Fonduer` application to tackle the task of
extracting formation measurements from paleontological publications.

## Dependencies

We use a few applications that you'll need to install and be sure are on your
PATH.

For OS X using [homebrew](https://brew.sh):

```bash
brew install poppler
brew install postgresql
```

On Debian-based distros:

```bash
sudo apt-get install poppler-utils
sudo apt-get install postgresql
```

For the Python dependencies, we recommend using a
[virtualenv](https://virtualenv.pypa.io/en/stable/). Once you have cloned the
repository, change directories to the root of the repository and run

```bash
virtualenv -p python3 .venv
```

Once the virtual environment is created, activate it by running

```bash
source .venv/bin/activate
```

Any Python libraries installed will now be contained within this virtual
environment. To deactivate the environment, simply run `deactivate`.

Then, install fonduer and any other python dependencies by running:

```bash
pip install -r requirements.txt
```

## Running

After installing Fonduer, and the additional python dependencies, just run:

```
jupyter notebook
```
