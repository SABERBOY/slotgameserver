# 快速部署指南 / Quick Deployment Guide

## 🚀 一键启动

### 使用Docker Compose（推荐）

```bash
# 1. 克隆项目
git clone <your-repo-url>
cd saber

# 2. 创建环境变量文件
cp .env.example .env

# 3. 启动所有服务
make compose-up

# 服务器将在 http://localhost:8000 运行
```

### 本地开发

```bash
# 1. 启动数据库服务
docker-compose -f docker-compose.dev.yml up -d

# 2. 运行服务器
cargo run

# 服务器将在 http://localhost:8000 运行
```

## 📋 可用的API端点

### 健康检查

- `GET /health` - 检查服务状态

### 基础端点

- `GET /` - 欢迎信息
- `GET /{name}` - 个性化问候

### Todo管理

- `GET /todos/{id}` - 获取待办事项
- `POST /todos/add` - 添加待办事项
- `PUT /todos/update/{id}` - 更新待办事项
- `DELETE /todos/delete/{id}` - 删除待办事项
- `GET /todos/list` - 列出所有待办事项

### 老虎机游戏

- `POST /slots/spin` - 旋转老虎机
- `GET /slots/jackpot` - 获取奖池信息
- `GET /slots/rtp` - 获取返奖率

## 🔧 常用命令

```bash
# 查看服务状态
make compose-logs

# 停止服务
make compose-down

# 构建Docker镜像
make docker-build

# 运行测试
make test

# 格式化代码
make fmt
```

## 🛠️ 故障排除

### 端口被占用

```bash
# 修改 .env 文件中的 SERVER_PORT
SERVER_PORT=8001
```

### 数据库连接失败

```bash
# 检查数据库是否运行
docker ps | grep postgres

# 查看数据库日志
docker logs saber_postgres_dev
```

## 📚 更多信息

- 完整部署文档: [DOCKER_DEPLOYMENT.md](./DOCKER_DEPLOYMENT.md)
- 项目进度: [PROGRESS.md](./PROGRESS.md)
- 项目说明: [README.md](./README.md)
