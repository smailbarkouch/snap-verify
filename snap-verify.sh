if [ "$#" -eq 0 ]; then
    echo "Please provide the snap package name and the public-key hash of the package."
    exit 1
fi

if [ -z "$2" ]; then
    echo "Please provide the public-key hash of the package."
    exit 1
fi

snap download "$1" --basename "$1"

snap known --remote account-key public-key-sha3-384="$2" > "$1".account-key

snap_sha3=$(cat "$1".assert | grep "snap-sha3-384" | sed "s/.*: //")
unverified_public_key_sha3=$(cat "$1".account-key | grep "public-key-sha3-384" | sed "s/.*: //")

if [ "$2" != "$unverified_public_key_sha3" ]; then
  echo "The public-key hash found in the account key file does not match the provided public-key hash."
  exit 1
fi

snap known --remote snap-build snap-sha3-384="$snap_sha3" > "$1".snap-build

sudo snap ack "$1".assert
sudo snap ack "$1".account-key
sudo snap ack "$1".snap-build || echo "Failed to assert snap-build, snap may be compromised."

sudo snap install "$1".snap

rm -f "$1".assert "$1".account-key "$1".snap-build "$1".snap

