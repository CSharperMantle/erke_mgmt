# 物理结构

## 用户与角色

### 角色

* `erke_admin`: 管理员
* `erke_auditor`: 审核员 (NOLOGIN)
* `erke_organizer`: 组织者 (NOLOGIN)
* `erke_student`: 学生 (NOLOGIN)

### 用户

* `erke_auditor_[0-9]+`: 审核员用户
  * 属于 `erke_auditor`
* `erke_organizer_[0-9]+`: 组织者用户
  * 属于 `erke_organizer`
* `erke_student_[0-9]+`:  学生用户
  * 属于 `erke_student`

## 活动状态定义

### 显式状态 (`activity.activity_state`)

详见PD CDM中的"活动状态域".

* 未开始签到: `0`
* 已开始签到: `1`
* 已开始签退: `2`
* 已审核: `3`

### 隐式状态

* 活动未开始报名: `CURRENT_TIMESTAMP < activity.activity_signup_start_time`
* 活动已开始报名: `CURRENT_TIMESTAMP >= activity.activity_signup_start_time AND CURRENT_TIMESTAMP < activity.activity_signup_end_time`
* 未过活动开始时间: `CURRENT_TIMESTAMP < activity_start_time`
* 已过活动开始时间: `CURRENT_TIMESTAMP >= activity_start_time`

## 视图

* 聚合评价 (`v_RateAgg`)
  * 提供每项活动的评分人数、评分均值、最高分与最低分

## 索引列

## 触发器

* 修改活动信息前检查活动状态 (`t_activity_update_check`; `BEFORE UPDATE`)
  1. 若活动并非处于未开始报名状态, 则抛出异常, 否则nop
* 报名前检查报名条件 (`t_signup_insert_check`; `BEFORE INSERT`)
  1. 检查是否满足以下条件 (AND):
     * 活动对该学生所在年级开放
     * 活动处于开放报名阶段
     * 学生尚未报名该活动
     * 活动时段与学生已报名时段未发生冲突
     * 活动未报满
  2. 不满足则抛出异常, 否则nop
* 发起签到前检查活动状态 (`t_initiatecheckin_insert_check_activity_state`; `BEFORE INSERT`)
  1. 若未过活动开始时间, 则抛出异常
  2. 若活动并非处于未开始签到或已开始签到状态, 则抛出异常, 否则nop
* 发起签到后更新活动状态 (`t_initiatecheckin_insert_update_activity_state`; `AFTER INSERT`)
  1. 若活动处于未开始签到状态, 则将其置为已开始签到状态, 否则nop
* 发起签退前检查活动状态 (`t_initiatecheckout_insert_check_activity_state`; `BEFORE INSERT`)
  1. 若活动并非处于已开始签到或已开始签退状态, 则抛出异常, 否则nop
* 发起签退后更新活动状态 (`t_initiatecheckout_insert_update_activity_state`; `AFTER INSERT`)
  1. 若活动处于已开始签到状态, 则将其置为已开始签退状态, 否则nop
* 审核前检查活动状态 (`t_audit_insert_check_activity_state`; `BEFORE INSERT`)
  1. 若活动并非处于已开始签到状态, 则抛出异常, 否则nop
* 审核后更新活动状态 (`t_audit_insert_update_activity_state`; `AFTER INSERT`)
  1. 若审核意见为通过, 则将活动状态置为已审核状态, 否则nop
* 评价前检查评价条件 (`t_rate_insert_check`; `BEFORE INSERT`)
  1. 若学生在该活动中签退过至少一次, 则nop, 否则抛出异常

## 存储过程与函数

* 报名 (`p_signup(student_id_ INTEGER, activity_id_ INTEGER, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 活动对该学生所在年级开放
     * 活动处于开放报名阶段
     * 学生尚未报名该活动
     * 活动时段与学生已报名时段未发生冲突
     * 活动未报满
  2. 插入相应数据
  3. 返回`okay_ = TRUE`
* 发起签到 (`p_initiate_checkin(organizer_id_ INTEGER, activity_id_ INTEGER, valid_duration_ TIME, OUT okay_ BOOL, OUT msg_ VARCHAR, OUT code_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 活动发起人相符
     * 已过活动开始时间
     * 活动处于未开始签到状态或已开始签到状态
  2. 随机生成一密令
  3. 插入相应数据
  4. 返回`okay_ = TRUE`与密令`code_`
* 发起签退 (`p_initiate_checkout(organizer_id_ INTEGER, activity_id_ INTEGER, valid_duration_ TIME, OUT okay_ BOOL, OUT msg_ VARCHAR, OUT code_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 活动发起人相符
     * 已过活动开始时间
     * 活动处于已开始签到状态
  2. 随机生成一密令
  3. 插入相应数据并返回`okay_ = TRUE`与密令`code_`
* 执行签到 (`p_do_checkin(code_ VARCHAR, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 当前时间内有学生已报名活动状态为已开始签到
  2. 对于所有符合条件活动, 执行:
     1. 检查是否满足以下条件 (AND):
        * 该活动存在当前时间有效的签到发起记录
        * 该签到密令与提供密令相符
     2. 插入相应数据
  3. 若成功进行至少一次插入, 则返回`okay_ = TRUE`
* 执行签退 (`p_do_checkout(code_ VARCHAR, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 当前时间内有学生已报名活动状态为已开始签退
  2. 对于所有符合条件活动, 执行:
     1. 检查是否满足以下条件 (AND):
        * 学生已在该活动中签到
        * 该活动存在当前时间有效的签退发起记录
        * 该签退密令与提供密令相符
     2. 插入相应数据
  3. 若成功进行至少一次插入, 则返回`okay_ = TRUE`
* 审核 (`p_audit(auditor_id_ INTEGER, activity_id_ INTEGER, audition_comment_ VARCHAR, audition_passed_ BOOL, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 当前活动是否处于已开始签退状态
  2. 插入相应数据
  3. 返回`okay_ = TRUE`
* 评价 (`p_rate(student_id_ INTEGER, activity_id_ INTEGER, rate_value_ DECIMAL, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 学生已在该活动中签退
  2. 插入相应数据
  3. 返回`okay_ = TRUE`
* 随机数生成 (`f_gen_random_checkinout_code() RETURNS VARCHAR`)
  1. 生成8位伪随机字母数字串, 返回
