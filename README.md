# erke_mgmt

HDU (2024-2025-1)-S0512290-01 《数据库原理课程设计》 课程项目

* DBMS：[openGauss](https://opengauss.org/zh/)/[PostgreSQL](https://www.postgresql.org/)
* CASE工具：[PowerDesigner](https://www.powerdesigner.biz/) 16.7
* 后端：[Rocket.rs](https://rocket.rs/) + [sqlx](https://docs.rs/crate/sqlx)
* 前端：React + [MUI 6](https://mui.com/material-ui/all-components/) + TypeScript + [Vite](https://vite.dev/)

## 项目结构

* [pd/](pd/)：PowerDesigner项目文件。（该目录下文件包含绝对路径，且在Git中视为二进制文件）
  * erke_powerdesigner.sws：工作区文件
  * erke_dfd.*：数据流图
  * erke_cdm.*：概念模型
  * erke_ldm.*：逻辑模型
  * erke_pdm.*：物理模型
* [notes/](notes/)：设计笔记
* [sql/](sql/)：SQL脚本
* [backend/](backend/)：后端服务器实现
* [frontend/](frontend/)：前端实现

## 构建

1. 使用PowerDesigner生成项目文件并将其导入PostgreSQL或openGauss
2. 创建角色
   1. 创建管理员角色`erke_admin`
   2. 执行[sql/role.sql](sql/role.sql)创建用户角色
3. 执行[sql/](sql/)下其他脚本完成存储过程、函数、触发器与视图
4. 构建前后端
   1. 在[backend/](backend/)目录下创建配置文件`.env`与`Rocket.toml`，具体见下
   2. 构建后端
   3. 构建前端
5. 运行后端

例如，DBMS运行于127.0.0.1:15432，且前端构建产物将放于`[backend]/../frontend/dist/`目录下，则`backend/.env`文件应包含如下内容：

```ini
DB_HOST = 127.0.0.1
DB_PORT = 15432
FRONTEND_PATH = ../frontend/dist/
```

`Rocket.toml`包含后端监听地址端口与Cookie加密配置。配置文件的具体含义见[Rocket.rs官方文档](https://rocket.rs/guide/v0.5/configuration/)。生成`secret_key`的方法详见[`CookieJar`的inline docs](https://api.rocket.rs/v0.5/rocket/http/struct.CookieJar#encryption-key)。样例结构如下：

```toml
[default]
address = "127.0.0.1"
port = 8000
secret_key = "[Base64-encoded secrets]"
```

前后端的构建命令如下：

```sh
cd backend
cargo build -r
cd ../frontend
yarn install
yarn build
```

之后在[backend/](backend/)下运行`cargo run -r`即可启动后端服务器。前端页面由服务器以静态路由形式serve。

## 许可协议

### 源代码

Copyright &copy; 2024-2025 Rong "Mantle" Bao <<baorong2005@126.com>>.

Copyright &copy; 2024-2025 Junyuan Huang <<2659045971@qq.com>>.

Copyright &copy; 2024-2025 Guangsheng Huang <<isaunoya@qq.com>>.

Copyright &copy; 2024-2025 Jingxuan Ji.

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but **WITHOUT ANY WARRANTY**; without even the implied warranty of **MERCHANTABILITY** or **FITNESS FOR A PARTICULAR PURPOSE**. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see [LICENSE-GPL-3.0-or-later](LICENSE-GPL-3.0-or-later) or <https://www.gnu.org/licenses/>.

### 设计笔记与文档

Copyright &copy; 2024-2025 Rong "Mantle" Bao <<baorong2005@126.com>>.

Copyright &copy; 2024-2025 Junyuan Huang <<2659045971@qq.com>>.

Copyright &copy; 2024-2025 Guangsheng Huang <<isaunoya@qq.com>>.

Copyright &copy; 2024-2025 Jingxuan Ji.

This work is licensed under Creative Commons Attribution-ShareAlike 4.0 International. To view a copy of this license, see [LICENSE-CC-BY-SA-4.0](LICENSE-CC-BY-SA-4.0) or visit <https://creativecommons.org/licenses/by-sa/4.0/>.
