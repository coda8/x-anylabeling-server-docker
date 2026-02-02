# 推送到 GitHub

本地已初始化 git 并完成首次提交（分支 `main`）。按下面步骤推送到你的 GitHub 仓库：

## 1. 在 GitHub 上创建仓库

1. 打开 https://github.com/new
2. 仓库名建议：`x-anylabeling-server-docker`
3. 选择 **Public**，**不要**勾选 “Add a README”（本地已有）
4. 创建仓库后记下仓库地址，例如：`https://github.com/你的用户名/x-anylabeling-server-docker.git`

## 2. 添加远程并推送

在项目目录下执行（把 `你的用户名/x-anylabeling-server-docker` 换成你的仓库）：

```bash
git remote add origin https://github.com/你的用户名/x-anylabeling-server-docker.git
git push -u origin main
```

若使用 SSH：

```bash
git remote add origin git@github.com:你的用户名/x-anylabeling-server-docker.git
git push -u origin main
```

## 3. 推送后的行为

- **Update upstream version** 会在你**任意一次 push**（改 Dockerfile、workflow 等）时自动跑一次，检查上游是否有新 release；若仅改 `version.json` 或 `README`（由 bot 更新）则不会触发，避免循环。
- 每次更新会记录上游的 **hash**（`upstream_sha`）到 `version.json`，构建时若该版本镜像已存在则**不会重复构建**。
