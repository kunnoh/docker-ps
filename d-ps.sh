#!/bin/bash

# Define column widths
COL1_WIDTH=40  # Image
COL2_WIDTH=15  # Container ID
COL3_WIDTH=40  # Ports
COL4_WIDTH=70  # Container name

# Function to print with proper padding for multi-line output
print_multiline() {
    local text="$1"
    local width=$2
    local pad_text="$3"
    
    if [[ -z "$text" ]]; then
        printf "%-${width}s" ""
        return
    fi
    
    # Handle first line
    local first_line=1
    echo "$text" | sed 's/,\s*/,\n/g' | while IFS= read -r line; do
        if [[ $first_line -eq 1 ]]; then
            printf "%-${width}s" "$line"
            first_line=0
        else
            echo
            printf "%s%-${width}s" "$pad_text" "$line"
        fi
    done
}

# Print header
printf "%-${COL1_WIDTH}s %-${COL2_WIDTH}s %-${COL3_WIDTH}s %-${COL4_WIDTH}s\n" "IMAGE" "CONTAINER ID" "PORTS" "CONTAINER NAME"
printf "%-${COL1_WIDTH}s %-${COL2_WIDTH}s %-${COL3_WIDTH}s %-${COL4_WIDTH}s\n" "$(printf '%*s' $COL1_WIDTH | tr ' ' '-')" "$(printf '%*s' $COL2_WIDTH | tr ' ' '-')" "$(printf '%*s' $COL3_WIDTH | tr ' ' '-')" "$(printf '%*s' $COL4_WIDTH | tr ' ' '-')"

# Process each docker container
docker ps --format "{{.Image}}|{{.ID}}|{{.Ports}}|{{.Names}}" | while IFS="|" read -r image id ports name; do
    # Format image name if needed
    if [[ ${#image} -gt $COL1_WIDTH ]]; then
        # Extract the last part after the last slash
        img_short=$(echo "$image" | rev | cut -d'/' -f1 | rev)
        if [[ ${#img_short} -lt ${#image} ]]; then
            image="$img_short"
        fi
    fi

    # Get short container ID
    id_short="${id:0:12}"
    
    # Begin the line
    printf "%-${COL1_WIDTH}s %-${COL2_WIDTH}s " "$image" "$id_short"
    
    # Handle ports with potential line breaks
    # Replace commas with newlines for better readability
    padding="$(printf '%*s' $((COL1_WIDTH + COL2_WIDTH + 2)) | tr ' ' ' ')"
    print_multiline "$ports" $COL3_WIDTH "$padding"
    
    # Print container name
    printf " %-${COL4_WIDTH}s\n" "$name"
done
