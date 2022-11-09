## 部署 confcenter

### 部署 webdavd 及 code-server

1. 创建持久化目录

```
sudo install -o 1000 -g 1000 -m 755 -d data/conf
sudo install -o 0 -g 0 -m 755 -d data/share/share
docker-compose up -d
sudo install -o 1000 -g 1000 -m 755 -d data/conf/projects
```

2. 生成 webdavd 密码

```
cd conf
../bin/webdavd --config webdavd-share.yaml genpass -p 123123
```

3. 修改配置文件， password 字段

- conf/webdavd-conf.yaml
- conf/webdavd-share.yaml

4. 启动服务

```
docker-compose.yml
```

5. 设置 code-server

```
cat > ./data/conf/.local/share/code-server/User/settings.json <<EOF
{
    "workbench.colorTheme": "Visual Studio Dark",
    "workbench.startupEditor": "newUntitledFile",
    "editor.dragAndDrop": false,
    "explorer.enableDragAndDrop": false,
    "editor.renderWhitespace": "all",
    "workbench.list.openMode": "doubleClick",
    "extensions.ignoreRecommendations": true,
    "files.trimTrailingWhitespace": true,
    "files.eol": "\n",
    "editor.fontSize": 16,
    "files.trimFinalNewlines": true,
    "editor.detectIndentation": false,
    "workbench.tree.expandMode": "doubleClick",
    "telemetry.telemetryLevel": "off",
    "window.menuBarVisibility": "toggle",
    "files.autoSave": "off",
    "window.openFoldersInNewWindow": "on",
    "window.openFilesInNewWindow": "default",
    "workbench.editor.restoreViewState": false,
    "diffEditor.ignoreTrimWhitespace": false
}
EOF
```
