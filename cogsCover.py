#!/usr/bin/env python3

import requests,json,random,shutil
from sys import argv
argv = argv[1:]

discogsKey = argv[1]
discogsSecret = argv[2]

def discogsSearch(albumTitle,discogsKey,discogsSecret):
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
                            return "No image available."

                else:
                    return "No image available."

            else:
                return "HTTP Error: {}".format(r.status_code)
        except:
            return "No release available."

    else:
        return "HTTP Error: {}".format(r.status_code)

if len(argv) >= 1:
    print(discogsSearch(argv[0],discogsKey,discogsSecret))
else:
    pass
