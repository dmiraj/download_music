#!/bin/python
# In this python script I want to intercept the name of a download object. 
# I will attempt to pur every html tag within a dictionary.
from bs4 import BeautifulSoup
import re
import sys

soup = BeautifulSoup(sys.argv[1], 'html.parser')
metadata = soup.find_all('meta', attrs={'content': re.compile('.*'), 'name': 'title'})
playlist_title = metadata[0].get('content')
print(playlist_title)

