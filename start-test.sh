
#!/bin/usr/env bash
mkdir src/
git clone https://github.com/sourcefuse/loopback4-microservice-catalog.git src/lb4

myArray=(
    "services"
)
cp start-test.sh src/lb4/
cp .nycrc src/lb4/
cp formated-output.js src/lb4/
cd src/lb4/
echo "Running tests"

currentPath=$(pwd)
coverage=""
for str in ${myArray[@]}; do
    echo "Scanning Directory $str"
    for dir in $currentPath/$str/*/          # list directories in the form "/tmp/dirname/"
    do
        dir=${dir%*/}
        folder="${dir##*/}"                 # remove the trailing "/"
        echo $folder                        # print everything after the final "/"
        cd $currentPath/$str/$folder
        cp $currentPath/.nycrc ./
        if [ ! -f package.json ]; then
            coverage+="$str/$folder:0.00:0.00:0.00:0.00\n"
            continue
        fi
        if [ ! -d node_modules ]; then
            echo "node_modules does not exist."
            npm install &> '/dev/null'
            npm i sinon --save-dev &> '/dev/null'
        fi
        if [ ! -d coverage ]; then
            cat <<< $(jq '(.scripts.coverage_auto) = "lb-nyc npm run test"' package.json) > package.json
            npm run coverage_auto &> '/dev/null'
        fi

        lines=$(jq .total.lines.pct coverage/coverage-summary.json)
        statements=$(jq .total.statements.pct coverage/coverage-summary.json)
        functions=$(jq .total.functions.pct coverage/coverage-summary.json)
        branches=$(jq .total.branches.pct coverage/coverage-summary.json)
        coverage+="$str/$folder:$statements:$branches:$functions:$lines\n"
    done
    node $currentPath/formated-output.js $currentPath/$str
done

{ echo Folder:% Stmts:% Branch:% Funcs: % Lines; printf "$coverage\n\n"; } | csvlook

