# 内容与运行时数据模型

本文件定义方案级公共接口。实际 TypeScript、Go 与 JSON Schema 应由这些定义生成或保持一一对应。

## 内容实体

### 故事包（`StoryPackage`）

```text
id: string
content_version: string
board: Board
access_condition: Condition | null
chapters: ChapterRef[]
endings: Ending[]
```

### 章节（`Chapter`）

```text
id: string
story_id: string
sequence: number
locale: zh-CN | en-US
title: string
license: CC-BY-SA-4.0
accounts: ForumAccountRef[]
clues: Clue[]
cards: CardDefinition[]
encounters: Encounter[]
scenes: Scene[]
```

### 版块（`Board`）

```text
id: string
name: string
description: string
board_kind: general | story
visibility_condition: Condition | null
access_condition: Condition | null
```

### 场景（`Scene`）

```text
id: string
entry_conditions: Condition[]
threads: Thread[]
choice_sets: ChoiceSet[]
interaction_stage: InteractionStage | null
on_enter: Effect[]
exits: SceneExit[]
```

### 帖子与楼层

```text
Thread { id, board_id, author_id, title, body, timestamp, status, comments }
Comment { id, author_id, body, timestamp, replies, state }
Reply { id, parent_id, author_id, body, timestamp, state }
```

`status` 支持 `normal`、`pinned`、`locked`、`deleted`、`restored`。剧情删除保留实体 ID。

### 交互选项（`InteractionChoice`）

```text
id: string
action_type: create_post | create_comment | create_reply
target_id: string
title: string | null
body: string
tone: investigate | support | challenge | cautious | publish | withdraw
conditions: Condition[]
effects: Effect[]
once: boolean
narrative_scope: main | flavor
interaction_cost: 0 | 1
```

`main` 选项的 `interaction_cost` 固定为 `1`，`flavor` 固定为 `0` 且 `effects` 必须为空。剧情选项确认后以玩家账号生成对应楼层。

### 互动时段（`InteractionStage`）

```text
id: string
interaction_limit: integer
show_budget: boolean
can_end_early: true
choice_set_ids: string[]
on_end: Effect[]
on_end_if_empty: Effect[]
```

互动时段可以覆盖同一场景内多个帖子和选项组。玩家手动结束与次数耗尽使用同一事务结算：若关键互动数为零，先执行 `on_end_if_empty`，再执行 `on_end`；随后结算由这些效果启动的遭遇，最后判断场景出口。遭遇重试不重复执行阶段结束效果。

`choice_set_ids` 必须引用当前场景内的选项组。只有列入其中的选项参与该阶段；关键互动成功后扣除 `interaction_cost`，额度为零时禁止继续提交关键互动。免费气氛互动仍受 `once` 约束，但不阻止玩家结束阶段。

## 条件与效果

条件（`Condition`）采用有标签联合：

```text
all, any, not
flag_equals
counter_at_least
has_clue
has_card
encounter_result
story_completed
route_equals
```

效果（`Effect`）采用有标签联合：

```text
set_flag
increment_counter
grant_clue
grant_card
remove_card
reveal_thread
change_thread_status
start_encounter
set_route
complete_chapter
complete_story
```

效果按数组顺序执行。执行前先验证全部参数；任何效果无效时整组选项不提交，避免论坛内容已发布但状态未更新。

场景出口（`SceneExit`）同样按数组顺序判断，只采用第一个满足条件的出口；重试后遗留的失败标记因此不能覆盖已经达成的胜利出口。

## 战斗实体

```text
CardDefinition {
  id, name, type, cost, rules_text, effects, keywords, story_scope
}

Encounter {
  id, name, player_credibility, enemy_integrity,
  enemy_pattern, reward_choices, victory_effects, defeat_effects
}
```

运行时战斗状态（`CombatState`）保存随机种子位置、抽牌堆、手牌、弃牌堆、带宽、可信度、防线、状态、回合和敌方意图。存档只能在完整动作结算后创建。

## 账号

```text
ForumAccount {
  id, username, role, badges, join_label, signature
}
```

`role` 支持 `player`、`community`、`editor`、`official`、`organization`。用户名不参与本地化，简介和签名可以本地化。

## 存档

```text
SaveEnvelope {
  schema_version,
  content_version,
  revision,
  updated_at,
  settings,
  current_run,
  permanent_archive
}
```

服务端把完整 payload 作为 JSON 保存，同时单独存储用户 ID、schema 版本、修订号、更新时间和内容摘要。服务端不得根据剧情结果授予权限；访问第二故事的判断由受校验存档和前端内容规则共同完成。

## YAML 约束

- 顶层键顺序固定为 `meta`、`accounts`、`clues`、`cards`、`encounters`、`scenes`。
- 时间戳使用无年份的故事显示字符串和独立排序序号，避免伪造具体年代。
- 多行正文使用 YAML `|-`。
- 所有引用使用稳定 ID，不使用标题或数组位置。
- 中英文件除本地化字符串外必须结构相同。

游戏设计与世界观内容采用 CC BY-SA 4.0 许可。
