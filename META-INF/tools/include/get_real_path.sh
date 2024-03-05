


input_path_file="$1"
tick=0
while file "$input_path_file" | grep -q symbolic ; do
    if (( tick > 20 )) ; then
        return 20
    else
        input_path_file="$(readlink "$input_path_file")"
    fi
    tick+=1
done
echo $(realpath "$input_path_file")