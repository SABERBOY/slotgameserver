# Docker部署指南

## 快速开始

### 1. 开发环境设置

```bash
# 复制环境变量文件
cp .env.example .env

# 启动开发环境数据库和Redis
docker-compose -f docker-compose.dev.yml up -d

# 运行本地开发服务器
cargo run
```

### 2. Docker镜像构建

```bash
# 构建Docker镜像
make docker-build

# 或者手动构建
docker build -t saber:latest .
```

### 3. 使用Docker Compose运行

```bash
# 启动所有服务
make compose-up

# 查看日志
make compose-logs

# 停止服务
make compose-down
```

## 生产环境部署

### 1. 准备工作

- 设置环境变量
- 配置SSL证书（如果需要HTTPS）
- 设置Docker Hub账号

### 2. 构建并推送镜像

```bash
# 设置Docker Hub用户名
export DOCKER_USERNAME=yourusername

# 构建并推送到Docker Hub
make docker-all
```

### 3. 部署到服务器

```bash
# 在生产服务器上
docker-compose --profile production up -d
```

## Makefile命令参考

### 开发命令
- `make build` - 构建Rust项目
- `make run` - 运行本地服务器
- `make test` - 运行测试
- `make fmt` - 格式化代码
- `make lint` - 运行代码检查

### Docker命令
- `make docker-build` - 构建Docker镜像
- `make docker-run` - 运行Docker容器
- `make docker-push` - 推送镜像到Docker Hub
- `make docker-all` - 构建并推送镜像
- `make docker-clean` - 清理Docker资源

### Docker Compose命令
- `make compose-up` - 启动所有服务
- `make compose-down` - 停止所有服务
- `make compose-logs` - 查看服务日志
- `make compose-build` - 构建服务
- `make compose-restart` - 重启服务

### 数据库命令
- `make db-init` - 初始化数据库
- `make db-migrate` - 运行数据库迁移

## 环境变量配置

必需的环境变量：
- `DATABASE_URL` - PostgreSQL连接字符串
- `SERVER_HOST` - 服务器监听地址
- `SERVER_PORT` - 服务器端口

可选的环境变量：
- `RUST_LOG` - 日志级别
- `REDIS_URL` - Redis连接字符串
- `JWT_SECRET` - JWT密钥

## GitHub Actions自动化

项目配置了GitHub Actions工作流，会在以下情况自动构建和发布Docker镜像：

1. 推送到main或develop分支
2. 创建新的版本标签（v*）
3. Pull Request到main分支（仅构建，不发布）

需要在GitHub仓库设置以下Secrets：
- `DOCKER_USERNAME` - Docker Hub用户名
- `DOCKER_PASSWORD` - Docker Hub密码

## 故障排除

### 端口冲突
如果端口已被占用，可以修改docker-compose.yml中的端口映射。

### 数据库连接失败
确保PostgreSQL服务正常运行，并且环境变量配置正确。

### 权限问题
确保Docker daemon正在运行，并且当前用户有权限访问Docker。

## 安全建议

1. 生产环境使用强密码
2. 启用HTTPS（使用nginx配置）
3. 定期更新Docker镜像
4. 限制数据库访问权限
5. 使用环境变量管理敏感信息