#!/usr/local/bin/python

import re, sys, urlparse, socket, time

def scriptremove(s):
    while 1:
        ind = s.find("<script")
        if ind == -1:
            break
        ind2 = s.find("</script>", ind)
        if ind2 == -1:
            # webmaster is fool
            break
        s = s[:ind] + s[ind2 + len("</script>"):]
    return s

sFileInName = ""
sUrl = ""
# linksToFetch[0] = 0  =>  fetching all links
#                 = 1  =>  only static links
#                 = 2  =>  only dynamic links
# linksToFetch[1] = 0  =>  all links
#                 = 1  =>  only inner links
#                 = 2  =>  only outer links
linksToFetch = [0, 0]


argv = sys.argv[1:]
i = 0
while i < len(argv):
    if argv[i] == "-i":
        i += 1
        sFileInName = argv[i]
    elif argv[i] == "-s":
        i += 1
        sUrl = argv[i]
        if sUrl.find("://") == -1:
            sUrl = "http://" + sUrl
        sShortUrl = sUrl[sUrl.find("://") + 3:]
        if sShortUrl.find("/") == -1:
            sUrl += "/"
            sShortUrl += "/"
        sRoot = sUrl[:sUrl.rindex("/") + 1]
        sSite = sShortUrl[:sShortUrl.find("/")]
        sProt = sUrl[:sUrl.find("://") + 3]
    elif argv[i] == "--static-only":
        linksToFetch[0] = 1
    elif argv[i] == "--dynamic-only":
        linksToFetch[0] = 2
    elif argv[i] == "--inner-only":
        linksToFetch[1] = 1
    elif argv[i] == "--outer-only":
        linksToFetch[1] = 2
    i += 1

#print "sUrl =", sUrl
#print "sShortUrl =", sShortUrl
#print "sRoot =", sRoot
#print "sSite =", sSite
#print "sProt =", sProt

s = ""
if sFileInName == "STDIN":
    # reading from stdin
    while 1:
        try:
            s += raw_input()
        except EOFError:
            break
else:
    # reading from file
    try:
        f = open(sFileInName, "rt")
    except IOError:
        sys.__stderr__.write("Error: file '" + sFileInName + "' not found.\n")
        sys.exit(1)
    s = "".join(f.readlines())
    f.close()

s = scriptremove(s)

# find all urls
p = re.compile("<a\\s+href\\s*=\\s*\"?(.*?)[\"|>]", re.I)
mtchs = p.findall(s)

for mtch in mtchs:
    if len(mtch) < 1:
        # empty href - webmaster is fool
        continue
    if mtch[0] == "#":
        # href links to this page
        continue
    if mtch.lower().find("mailto:") != -1:
        # href is e-mail
        continue
    if mtch.lower().find("javascript") != -1:
        # href is javascript
        continue
    # converting to absolute URL
    if mtch.find("://") == -1:
        if mtch[0] == "/":
            # like /dir/to/page.html
            mtch = sProt + sSite + mtch
        else:
            # like dir/to/page.html
            if sShortUrl.find("/") == -1:
                mtch = sUrl + mtch
            else:
                mtch = sRoot + mtch
    # removing anchors
    # like http://site.ru/dir/to/page.html#par5 -> http://site.ru/dir/to/page.html
    ind = mtch.find("#")
    if ind != -1:
        mtch = mtch[:ind]

    if linksToFetch[0] == 1:
        # static only
        if mtch.find("?") != -1:
            continue
    if linksToFetch[0] == 2:
        # dynamic only
        if mtch.find("?") == -1:
            continue
    if linksToFetch[1] == 1:
        # inner only
        if not mtch.startswith(sProt + sSite):
            continue
    if linksToFetch[1] == 2:
        # inner only
        if mtch.startswith(sProt + sSite):
            continue

    #whattosend += mtch + " "
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.connect(("localhost", 9999))
    sock.send(mtch)
    print mtch
    sock.close()
    #time.sleep(10)
    #print mtch


