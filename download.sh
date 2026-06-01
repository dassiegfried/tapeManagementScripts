cd 


FILE="HDD.30.05.2026.zfs.zstd.age.04"
curl -L -C - https://b2.yeetin.me/$FILE.sha1?key=$KEY -o $FILE.sha1.remote
curl -L -C - https://b2.yeetin.me/$FILE?key=$KEY -o $FILE
while (( $(du -m $FILE | cut -f1) < 700000 ));
do
  sleep 120
  echo "file not big enough yet"
  curl -L -C - https://b2.yeetin.me/$FILE?key=$KEY -o $FILE
done

echo "download successfull starting checksum calc"
sha1sum $FILE > $FILE.sha1
