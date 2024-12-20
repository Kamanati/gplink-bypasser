#!/data/data/com.termux/files/usr/bin/bash

# Initial link

# Check if the first argument is provided
if [ -z "$1" ]; then
  echo "Please provide a URL as the first argument."
  exit 1
fi

# Check if the argument contains "gplink" in the URL
if [[ ! "$1" =~ gplink ]]; then
  echo "The first argument is not a valid URL containing 'gplink'."
  exit 1
fi


echo "Bypassing: $1"

#exit

initial_url="$1"

self_update(){
    echo 
}

# Function to get bypass parameters
get_bypass_parameters() {
    url="$1"
    
    # Make initial request to get the final redirected URL
    #redirected_url=$(curl -Ls -o /dev/null -w %{url_effective} "$url")
    redirected_url=$(curl -Ls -o /dev/null -w %{url_effective} "$url" \
    -H "User-Agent: Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.105 Mobile Safari/537.36" \
    -H "Accept: application/json, text/plain, */*" \
    -H "Accept-Language: en-US,en;q=0.9" \
    -H "Accept-Encoding: gzip, deflate, br" \
    -H "Connection: keep-alive")

    # Parse parameters from the redirected URL
    params=$(echo "$redirected_url" | grep -oP '(\?|\&)lid=\K[^&]+' | head -n 1)
    pid=$(echo "$redirected_url" | grep -oP '(\?|\&)pid=\K[^&]+' | head -n 1)
    plid=$(echo "$redirected_url" | grep -oP '(\?|\&)plid=\K[^&]+' | head -n 1)
    vid=$(echo "$redirected_url" | grep -oP '(\?|\&)vid=\K[^&]+' | head -n 1)


    # Check if all parameters are present
    if [[ -n "$params" && -n "$pid" && -n "$plid" && -n "$vid" ]]; then
        echo "lid=$params&pid=$pid&plid=$plid&vid=$vid"
    else
        echo "Error: Missing necessary parameters."
        exit 1
    fi
}

# Function to make bypass request
make_bypass_request() {
    params="$1"
    
    # Extract parameters
    lid=$(echo "$params" | awk -F'&' '{print $1}' | cut -d'=' -f2)
    pid=$(echo "$params" | awk -F'&' '{print $2}' | cut -d'=' -f2)
    vid=$(echo "$params" | awk -F'&' '{print $4}' | cut -d'=' -f2)

    # Build the bypass URL
    bypass_url="https://gplinks.co/$lid/?pid=$pid&vid=$vid"

    if [ "$pid" == "1016614" ]; then
               echo "Admin: This GpLink Cannote be bypassed, becasue its admin's gplinks"
               read -p "Enter any key to open browser and do manually....."
               am start -a android.intent.action.VIEW -d  "$clean_url"
               exit 1
    fi

    # Make POST requests for each status
    for status in 1 2 3; do
        imps=$((status * 2))  # Adjust `imps` per your specific requirements
        curl -X POST "https://gplinks.co/track/data.php" \
            -H "User-Agent: Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.105 Mobile Safari/537.36" \
            -H "Accept: application/json, text/plain, */*" \
            -H "Accept-Language: en-US,en;q=0.9" \
            -H "Accept-Encoding: gzip, deflate, br" \
            -H "Connection: keep-alive" \
            -d "request=setVisitor&status=$status&imps=$imps&vid=$vid" \
            -s  &> /dev/null;

        printf "\r Bypassing Level $status out of 3"

        if [[ $? -ne 0 ]]; then
            echo "Failed to make request with status $status"
            exit 1
        fi
    done

    # Print final bypass URL
    echo "Bypass successful! Redirecting to the final URL:"
    echo "$bypass_url"
    am start -a android.intent.action.VIEW -d $bypass_url
}

# Run the bypass
params=$(get_bypass_parameters "$initial_url")
make_bypass_request "$params"
