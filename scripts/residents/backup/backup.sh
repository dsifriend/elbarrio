#!/bin/bash

# Set your credentials
USERNAME="laesquina.elbarrio.social"
PASSWORD="ok6a-aobr-wktq-wv2p"
LIST_URI="at://did:plc:uhmf7ih4gk7kz4zqpbammowa/app.bsky.graph.list/3lh6birkgfh2y"

# Step 1: Get Access Token
TOKEN=$(curl -s -X POST "https://bsky.social/xrpc/com.atproto.server.createSession" \
    -H "Content-Type: application/json" \
    -d "{\"identifier\": \"$USERNAME\", \"password\": \"$PASSWORD\"}" \
    | grep -o '"accessJwt":"[^"]*"' | sed 's/"accessJwt":"//;s/"$//')

# Step 2: Fetch List Members with Pagination
> list.json # Clear old data
> list_handles.txt # Clear old handles

CURSOR=""
while : ; do
    RESPONSE=$(curl -s -X GET "https://bsky.social/xrpc/app.bsky.graph.getList?list=$LIST_URI&cursor=$CURSOR" \
        -H "Authorization: Bearer $TOKEN")
    
    # Save raw data (optional)
    echo "$RESPONSE" >> list.json

    # Extract handles
    echo "$RESPONSE" | grep -o '"handle":"[^"]*"' | sed 's/"handle":"//;s/"$//' >> list_handles.txt

    # Get cursor for next page
    CURSOR=$(echo "$RESPONSE" | grep -o '"cursor":"[^"]*"' | sed 's/"cursor":"//;s/"$//')

    # If there's no cursor, stop fetching
    [[ -z "$CURSOR" ]] && break
done

echo "Full list saved to list_handles.txt"

