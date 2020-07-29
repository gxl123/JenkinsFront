# phone2

## Project setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Lints and fixes files
```
npm run lint
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).

部署到openshift
oc login $url --token=$token 例: oc login https://master.lab.xkgs.gd.csg.local:8443 --token=XGmfI6ti7KNg9fTeiPwQ3DJjbsBxjJLPkrmMw1UP43E

cd ~/VscodeProjects/fe-csgit-project-management

./build-deploy.sh gghqygl-frontend --from-dir ./dist