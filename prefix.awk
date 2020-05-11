#!/usr/bin/env awk
{
  filesize++;
  print prefix, "§|§", $0;
}

BEGINFILE {
  filesize = 0;
}

ENDFILE {
  if (filesize > 1) {
    print "§";
  }
}

