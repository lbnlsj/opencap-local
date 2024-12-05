# 申明：所有代码都是基于斯坦福大学的开源opencap修改而来，仅用于研究学习目的
## opencap-viewer
### 使用node 16版本，并且chartjs-plugin-zoom如果安装失败的话请安装1.2.1版本的这个库
### nrm 可以管理源

## opencap-api
### ！需先安装postgresql
### 首先要安装postgresql，然后使用命令 python manage.py makemigrations/migrate 进行数据库迁移

-- 进入 psql 后执行以下命令：
CREATE DATABASE opencap;
CREATE USER opencap WITH PASSWORD 'admin123';
ALTER ROLE opencap SET client_encoding TO 'utf8';
ALTER ROLE opencap SET default_transaction_isolation TO 'read committed';
ALTER ROLE opencap SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE opencap TO opencap;