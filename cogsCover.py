#!/usr/bin/env python3

# Omg don't even look at this nasty code.

import requests,json,random,shutil
from sys import argv
from os import path


def discogsSearch(albumTitle,discogsKey,discogsSecret,doNotFetchPath):
    headers = {'user-agent':'cogsCoverScraper 0.1','Authorization':'Discogs key={},secret={}'.format(discogsKey,discogsSecret)}
    searchURL = 'https://api.discogs.com/database/search?q={}&title'.format(albumTitle)

    r = requests.get(searchURL, headers=headers)
    if r.status_code == 200:
        searchDict = r.json()
        try:
            releaseID = searchDict['results'][0]['id']
            releaseURL = 'https://api.discogs.com/masters/{}'.format(releaseID)
            r = requests.get(releaseURL,headers=headers)
            if r.status_code == 200:
                releaseDict = r.json()
                if "images" in releaseDict:
                    for imageDict in releaseDict['images']:
                        if imageDict['type'] == 'primary': # Only pull primary image
                            r = requests.get(imageDict['resource_url'],headers=headers, stream=True) # Fancy downloading. Stream allows it to break into chunks and be stored with shutil when requests sees it as a raw file.
                            with open('/tmp/image.jpg','wb') as f:
                                r.raw.decode_content = True
                                shutil.copyfileobj(r.raw,f)
                            return "Successfully fetched a cover."
                        elif imageDict['type'] == 'secondary':
                            r = requests.get(imageDict['resource_url'],headers=headers, stream=True) # Fancy downloading. Stream allows it to break into chunks and be stored with shutil when requests sees it as a raw file.
                            with open('/tmp/image.jpg','wb') as f:
                                r.raw.decode_content = True
                                shutil.copyfileobj(r.raw,f)
                            return "Successfully fetched a cover."
                        else:
                            with open(doNotFetchPath, "a") as bl:
                                bl.write(albumTitle + "\n")
                            return "No image available."

                else:
                    with open(doNotFetchPath, "a") as bl:
                        bl.write(albumTitle + "\n")
                    return "No image available."

            else:
                with open(doNotFetchPath, "a") as bl:
                    bl.write(albumTitle + "\n")
                return "HTTP Error: {}".format(r.status_code)
        except:
            with open(doNotFetchPath, "a") as bl:
                bl.write(albumTitle + "\n")
            return "No release available."

    else:
        return "HTTP Error: {}".format(r.status_code)

argv = argv[1:]
albumTitle = argv[0]
discogsKey = argv[1]
discogsSecret = argv[2]
doNotFetchPath = path.expanduser("~/.mpd-notify/doNotFetch.txt")
doNotFetch = open(doNotFetchPath).read().splitlines() # Albums to not scrape art for. If scraping fails, the album will be added to the doNotFetch.
if len(argv) >= 1:
    if albumTitle not in doNotFetch:
        print("Fetching {}...".format(albumTitle),discogsSearch(albumTitle,discogsKey,discogsSecret,doNotFetchPath))
    else:
        print("{} in doNotFetch, not attempting to fetch.".format(albumTitle))
else:
    pass
