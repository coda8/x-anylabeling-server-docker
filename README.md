# X-AnyLabeling-Server Docker

自动构建 [X-AnyLabeling-Server](https://github.com/CVHub520/X-AnyLabeling-Server) 的 Docker 镜像，并发布到 GitHub Container Registry。

[xx025](https://github.com/xx025) 家的机器人 [coda8](https://github.com/coda8/coda8) 建的～想认识它？[点它](https://github.com/coda8/coda8)。

## 镜像标签

| 标签 | 描述 |
|------|------|
| `latest` | 最新稳定版本 (CPU) |
| `cpu` | 最新 CPU 版本 |
| `cuda` | 最新 CUDA 版本 |
| `cuda12.6` | CUDA 12.6 版本 |
| `<version>` | 指定版本 (CPU) |
| `<version>-cpu` | 指定版本 CPU |
| `<version>-cuda` | 指定版本 CUDA |

## 快速开始

### 拉取镜像

```bash
# CPU 版本
docker pull ghcr.io/coda8/x-anylabeling-server-docker:latest
# 或指定 cpu 标签
docker pull ghcr.io/coda8/x-anylabeling-server-docker:cpu

# CUDA 版本 (需要 NVIDIA GPU 和 nvidia-docker)
docker pull ghcr.io/coda8/x-anylabeling-server-docker:cuda
```

> **说明**: 镜像在 [coda8](https://github.com/coda8/coda8) 账户下；若您 Fork 本仓库，请改成您自己的 GitHub 用户名。

### 运行容器

#### CPU 版本

```bash
docker run -d \
  --name x-anylabeling-server \
  -p 8000:8000 \
  -v ./configs:/app/configs \
  -v ./weights:/app/weights \
  ghcr.io/coda8/x-anylabeling-server-docker:latest
```

#### CUDA 版本

```bash
docker run -d \
  --name x-anylabeling-server \
  --gpus all \
  -p 8000:8000 \
  -v ./configs:/app/configs \
  -v ./weights:/app/weights \
  ghcr.io/coda8/x-anylabeling-server-docker:cuda
```

### 使用 Docker Compose

创建 `docker-compose.yml`:

```yaml
version: '3.8'

services:
  x-anylabeling-server:
    image: ghcr.io/coda8/x-anylabeling-server-docker:latest
    container_name: x-anylabeling-server
    ports:
      - "8000:8000"
    volumes:
      - ./configs:/app/configs
      - ./weights:/app/weights
      - ./logs:/app/logs
    environment:
      - WORKERS=4
    restart: unless-stopped
    # 如果使用 CUDA 版本，取消下面的注释
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: all
    #           capabilities: [gpu]
```

启动服务:

```bash
docker compose up -d
```

## 验证服务

```bash
# 健康检查
curl http://localhost:8000/health

# 列出可用模型
curl http://localhost:8000/v1/models
```

## 配置

### 环境变量

| 变量 | 描述 | 默认值 |
|------|------|--------|
| `HOST` | 监听地址 | `0.0.0.0` |
| `PORT` | 监听端口 | `8000` |
| `WORKERS` | Worker 数量 | `1` |
| `LOG_LEVEL` | 日志级别 | `INFO` |

### 自定义配置文件

您可以挂载自定义配置文件:

```bash
docker run -d \
  -p 8000:8000 \
  -v /path/to/your/server.yaml:/app/configs/server.yaml \
  -v /path/to/your/models.yaml:/app/configs/models.yaml \
  ghcr.io/coda8/x-anylabeling-server-docker:latest \
  x-anylabeling-server --config /app/configs/server.yaml --models-config /app/configs/models.yaml
```

### 模型权重

将模型权重放置在 `weights` 目录中，并挂载到容器:

```bash
-v ./weights:/app/weights
```

## 与 X-AnyLabeling 客户端连接

1. 在 X-AnyLabeling 客户端的配置文件 (`~/.xanylabelingrc`) 中设置:

```yaml
remote_server_settings:
  server_url: http://<server-ip>:8000
  api_key: ""  # 如果启用了认证，填写 API Key
```

2. 启动 X-AnyLabeling，按 `Ctrl+A` 启用 AI 自动标注
3. 在模型下拉菜单中选择 **CVHub** > **Remote-Server**

## 构建与发布机制

本仓库**不采用定时检查**，而是**订阅机制**：仅在被触发时检查上游 [X-AnyLabeling-Server](https://github.com/CVHub520/X-AnyLabeling-Server) 的 **Releases** → 更新 `version.json` 与 README → 推送后自动触发 Docker 镜像构建。

**当前跟随的上游版本:** **v0.0.7**（由 [Update upstream version](.github/workflows/update-version.yml) 工作流更新）

### 流程说明

1. **触发**方式：本仓库 **push**（除仅改 version.json/README 外）、订阅触发或手动运行 **Update upstream version**。
2. 工作流检查上游最新 release，若有新版本则更新 `version.json`（含 `upstream_sha`）与 README 并推送到本仓库。
3. **推送**触发 **Build and Push Docker Images**，按 `version.json` 中的版本构建；若该版本镜像已存在则**不重复构建**（以版本 tag 与上游 hash 为准）。

### 订阅机制（如何触发更新）

任选一种方式，在「上游发新 release 时」或「您认为该检查时」触发本仓库更新：

| 方式 | 说明 |
|------|------|
| **A. GitHub 关注 + 手动运行** | 在 [X-AnyLabeling-Server](https://github.com/CVHub520/X-AnyLabeling-Server) 点 **Watch** → **Custom** → 勾选 **Releases**。收到新 release 通知后，到本仓库 **Actions** → **Update upstream version** → **Run workflow**。 |
| **B. 外部自动化调用** | 用 n8n、Zapier、自建脚本等监控上游 [Releases RSS](https://github.com/CVHub520/X-AnyLabeling-Server/releases.atom) 或 API，当有新 release 时向 GitHub 发起 `repository_dispatch`，触发本仓库更新（见下方 curl 示例）。 |
| **C. 上游仓库配合** | 若上游在 release 流程中增加一步：对本仓库发起 `repository_dispatch`（event_type: `upstream-release`），即可实现「一发 release 即自动更新本仓库」。 |

#### 方式 B：用 curl 触发本仓库更新（需 PAT）

将 `YOUR_GITHUB_PAT` 换成本仓库有写权限的 [Personal Access Token](https://github.com/settings/tokens)（勾选 `repo`），`OWNER/REPO` 换成本仓库（如 `coda8/x-anylabeling-server-docker`）：

```bash
curl -X POST -H "Authorization: token YOUR_GITHUB_PAT" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/OWNER/REPO/dispatches \
  -d '{"event_type":"upstream-release"}'
```

自动化时：用定时任务或「RSS 有新条目」等条件执行上述请求即可，无需本仓库内再跑定时 workflow。

### 手动触发

- **仅更新版本**：Actions → **Update upstream version** → Run workflow  
- **仅构建镜像**：Actions → **Build and Push Docker Images** → Run workflow（可指定版本或留空使用 `version.json`）

## Fork 使用说明

如果您想 Fork 此仓库使用:

1. Fork 此仓库到您的 GitHub 账户
2. 进入仓库 Settings > Actions > General
3. 在 "Workflow permissions" 中选择 "Read and write permissions"
4. 更新 README 中的镜像地址为您的用户名
5. 订阅上游 Releases 后，在收到新版本通知时手动运行工作流

## 系统要求

### CPU 版本
- Docker 20.10+
- 至少 8GB 内存 (推荐 16GB+)
- 至少 20GB 磁盘空间

### CUDA 版本
- Docker 20.10+
- NVIDIA Docker Runtime
- NVIDIA 驱动 525+ (支持 CUDA 12.x)
- NVIDIA GPU (推荐 8GB+ 显存)
- 至少 16GB 内存
- 至少 30GB 磁盘空间

## 许可证

本项目遵循 [AGPL-3.0](LICENSE) 许可证。

原项目 X-AnyLabeling-Server 由 [CVHub520](https://github.com/CVHub520) 开发，遵循 AGPL-3.0 许可证。本仓库由 [coda8](https://github.com/coda8/coda8)（xx025 的 AI 助手）创建，归属 [xx025](https://github.com/xx025)。

## 相关链接

- [xx025](https://github.com/xx025) - 归属（老板/产品）
- [coda8](https://github.com/coda8/coda8) - 镜像与仓库在这里（xx025 的 AI 助手）
- [X-AnyLabeling-Server](https://github.com/CVHub520/X-AnyLabeling-Server) - 上游项目
- [X-AnyLabeling](https://github.com/CVHub520/X-AnyLabeling) - 客户端应用
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) - 镜像托管文档
