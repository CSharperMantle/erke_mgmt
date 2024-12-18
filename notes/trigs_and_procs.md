# 触发器与存储过程

## 触发器

## 存储过程与函数

* 报名 (`p_signup(student_id_ INTEGER, activity_id_ INTEGER, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 活动对该学生所在年级开放
     * 活动处于开放报名阶段
     * 学生尚未报名该活动
     * 活动时段与学生已报名时段未发生冲突
  2. 插入相应数据
  3. 返回`okay_ = TRUE`
* 发起签到 (`p_initiate_checkin(organizer_id_ INTEGER, activity_id_ INTEGER, valid_duration_ TIME, OUT okay_ BOOL, OUT msg_ VARCHAR, OUT code_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 活动发起人相符
     * 活动处于进行中阶段
     * 活动尚未发起任何签退
  2. 随机生成一密令
  3. 插入相应数据
  4. 返回`okay_ = TRUE`与密令`code_`
* 发起签退 (`p_initiate_checkout(organizer_id_ INTEGER, activity_id_ INTEGER, valid_duration_ TIME, OUT okay_ BOOL, OUT msg_ VARCHAR, OUT code_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 活动发起人相符
     * 活动处于进行中阶段
     * 活动已发起至少一次签退
  2. 随机生成一密令
  3. 插入相应数据并返回`okay_ = TRUE`与密令`code_`
* 执行签到 (`p_do_checkin(code_ VARCHAR, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 当前时间内有学生已报名活动状态为进行中
  2. 对于所有符合条件活动, 执行:
     1. 检查是否满足以下条件 (AND):
        * 该活动存在当前时间有效的签到发起记录
        * 该签到密令与提供密令相符
     2. 插入相应数据
  3. 若成功进行至少一次插入, 则返回`okay_ = TRUE`
* 执行签退 (`p_do_checkout(code_ VARCHAR, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 当前时间内有学生已报名活动状态为进行中
  2. 对于所有符合条件活动, 执行:
     1. 检查是否满足以下条件 (AND):
        * 学生已在该活动中签到
        * 该活动存在当前时间有效的签退发起记录
        * 该签退密令与提供密令相符
     2. 插入相应数据
  3. 若成功进行至少一次插入, 则返回`okay_ = TRUE`
* 审核 (`p_signup(auditor_id_ INTEGER, activity_id_ INTEGER, audition_comment_ VARCHAR, audition_passed_ BOOL, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 当前活动是否处于待审核状态
  2. 插入相应数据
  3. 返回`okay_ = TRUE`
* 评价 (`p_rate(student_id_ INTEGER, activity_id_ INTEGER, rate_value_ DECIMAL, OUT okay_ BOOL, OUT msg_ VARCHAR)`)
  1. 检查是否满足以下条件 (AND):
     * 当前时间内有学生已签退活动
  2. 插入相应数据
  3. 返回`okay_ = TRUE`
* 随机数生成 (`f_gen_random_checkinout_code() RETURNS VARCHAR`)
  1. 生成8位伪随机字母数字串, 返回
