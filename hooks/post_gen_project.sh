#!/bin/sh

set -e
echo "Hello \{\{ name \}\}" | sed 's/\\//g' > AarKay/AarKayTemplates/Template.txt.stencil
sh scripts/run
mv _gitignore .gitignore
git init
git add -A .
git commit -m "Initial Commit"
