echo "global-ignores =" `cat .gitignore| grep -Ev '^#|^\s*$'| tr "\n" " "` >> .subversion/config
echo '$m/\[miscellany]'"\n"'wq' | ex .subversion/config

