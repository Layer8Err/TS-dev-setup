#!/bin/bash
# Install Node Package Manager + Typescript deps
# Setup environment for TS dev

sudo apt install -y npm

# Configure this folder for Typescript dev
npm init -y
npm install --save typescript @types/node

# Create Typescript basic src
mkdir src
echo "Creating Hello World Typescript file..."
touch src/boot.ts
read -d '' bootts << "EOF"
function speak(message: string) {
  console.log(message);
}

speak('Hello World!');
EOF
echo "$bootts" >> src/boot.ts

#echo "Autogen tsconfig..."
#./node_modules/.bin/tsc --init
echo "Creating boilerplate tsconfig..."
read -d '' tsconf << "EOF"
{
  // This attribute will hold all the compile option of TypeScript
  "compilerOptions": {
    // Source code location
    "rootDir": "src",
    // Where you want to put our compiled code
    "outDir": "build",

    // Which ES library you want to include
    // If the project will be used as a server, no browser, then use the esnext or one of the latest versions)
    // Otherwise, consider ES6 but
    // If you omit the option it will use:
    //  For --target ES5: DOM,ES5,ScriptHost
    //  For --target ES6: DOM,ES6,DOM.Iterable,ScriptHost
    "lib": ["es2018", "dom"],

    // Which ES version you want to target during compilation, this is reliable to the `lib` option
    // This options is really important regarding the project usage (backend or frontend)
    // Put ES5 if you need to IE compatibility, otherwise you can target at least es2017 or es2018
    // Ref: @see https://node.green
    "target": "es2018",

    // How you want to resolve your module, TypeScript tends to use the `classic` way but let's
    // stick with the `node` one
    // @see https://www.typescriptlang.org/docs/handbook/module-resolution.html
    "moduleResolution": "node",

    // From documentation, Specify module code generation
    // commonjs === (target = ES3 OR ES5)
    // Otherwise use es6
    "module": "es6",

    // Sourcemap is usefull for the debugging part
    // During dev you should active this one and then disable it in production
    "sourceMap": true,

    // Reolve `.json`file without tricking with a custom and bad json.d.ts file
    "resolveJsonModule": true,

    // Allow to import node module without `import *`
    // Ex import express from 'express'
    "esModuleInterop": true
  },

  // The folder or files you want to exclude
  // You can also use regex e.g. `**/*.spec.ts`
  "exclude":[
    "node_modules",
    "build"
  ]
}
EOF
echo "$tsconf" >> ./tsconfig.json

# Use watcher for reload on change
echo "Installing NPM watcher for changes..."
sudo npm install --save-dev nodemon ts-node

# Create nodemon config
read -d '' nodemonjson << "EOF"
{
  "watch": ["src"],
  "ext": "ts js json proto",
  "exec": "ts-node ./src/boot.ts"
}
EOF
echo "Creating JSON config for nodemon..."
echo "$nodemonjson" >> ./nodemon.json

# Autostart nodemon for dev
# Entry should be under "scripts": {
echo "Adding nodemon autostart entry to package.json..."
cp ./package.json ./package.json.mod
scrlnum=$(grep -Fn -m1 "scripts" ./package.json | cut -d ":" -f 1)
head -n $scrlnum ./package.json.mod > ./package.json
spc='    '
echo "${spc}\"start:dev\": \"nodemon\"," >> ./package.json
lc=$(wc -l < ./package.json.mod)
tl="$(($lc-$scrlnum))"
tail -n $tl ./package.json.mod >> ./package.json
rm ./package.json.mod

# Testing dev build/run process

## Transpile Typescript
#echo "Transpiling Typescript to Javascript..."
#./node_modules/.bin/tsc 

## Run Javascript
#echo "Running transpiled Javascript..."
#node ./build/boot.js

## Launch Dev environment 
echo "Launching TS dev environment..."
npm run start:dev