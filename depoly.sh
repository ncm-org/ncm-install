#!/bin/bash
cat ./install.sh >./sh.ncm.ink/index.html

cd ./sh.ncm.ink || exit
cat ../install.sh >./index.html
git commit index.html -m "feat: install ncm"
git push

cd ..
git commit -am "feat: install ncm"
git push
