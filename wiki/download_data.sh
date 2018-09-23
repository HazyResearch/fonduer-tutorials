echo "Downloading hardware tutorial data..."
url=http://i.stanford.edu/hazy/share/fonduer/president_tutorial_data.tar.gz
data_tar=president_tutorial_data
if type curl &>/dev/null; then
    curl -RLO $url
elif type wget &>/dev/null; then
    wget -N $url
fi

echo "Unpacking hardware tutorial data..."
tar -zxvf $data_tar.tar.gz -C data

echo "Deleting tar file..."
rm $data_tar.tar.gz

echo "Done!"
