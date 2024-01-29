#!/bin/bash

#github action release.sh

set -x
function RETVAL() {
  rt=$1
  if [ $rt != 0 ]; then
    echo $rt
    exit 1
  fi
}

#当前目录
cpath=$(pwd)

#ver=`cat server/base/app_ver.go | grep APP_VER | awk '{print $3}' | sed 's/"//g'`
ver=$(cat version)
echo "当前版本 $ver"

echo "编译前端项目"
cd $cpath/web
#国内可替换源加快速度
#npx browserslist@latest --update-db
#yarn install
#yarn run build
#RETVAL $?
#rm -rf $cpath/server/ui
#cp -rf $cpath/web/ui . $cpath/server/ui

echo "编译二进制文件"
cd $cpath/server

# -tags osusergo,netgo,sqlite_omit_load_extension
flags="-v -trimpath"
ldflags="-s -w -extldflags '-static' -X main.appVer=$ver -X main.commitId=$(git rev-parse HEAD) -X main.date=$(date --iso-8601=seconds)"

#github action
gopath=$(go env GOPATH)
go mod tidy

#使用 musl-dev 编译
docker run -q --rm -v $PWD:/app -v $gopath:/go -w /app --platform=linux/amd64 \
  golang:1.20-alpine3.19 go build -o anylink_amd64 $flags -ldflags "$ldflags"
#arm64交叉编译
docker run -q --rm -v $PWD:/app -v $gopath:/go -w /app --platform=linux/arm64 \
  golang:1.20-alpine3.19 go build -o anylink_amd64 $flags -ldflags "$ldflags"

./anylink_amd64 -v
./anylink_arm64 -v

exit 0

cd $cpath

echo "整理部署文件"
deploy="anylink-deploy"
rm -rf $deploy ${deploy}.tar.gz
mkdir $deploy
mkdir $deploy/log

cp -r server/anylink $deploy
cp -r server/bridge-init.sh $deploy
cp -r server/conf $deploy

cp -r systemd $deploy
cp -r LICENSE $deploy
cp -r home $deploy

tar zcvf ${deploy}.tar.gz $deploy

#注意使用root权限运行
#cd anylink-deploy
#sudo ./anylink --conf="conf/server.toml"
