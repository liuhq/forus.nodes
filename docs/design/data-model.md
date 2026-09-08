# 内容与运行时数据模型

本文定义方案级公共接口，后续 TypeScript、Go 与 JSON Schema 应保持一一对应。

## 内容实体

```text
StoryPackage {
  id: string
  content_version: string
  duration_days: integer
  boards: Board[]
  days: DayRef[]
  routes: RouteDefinition[]
  endings: Ending[]
}

StoryDay {
  day_id: string
  story_id: string
  sequence: integer
  display_date: string
  locale: zh-CN | en-US
  interaction_limit: integer
  accounts: ForumAccountRef[]
  clues: Clue[]
  cards: CardDefinition[]
  encounters: Encounter[]
  scenes: Scene[]
  on_enter: Effect[]
  on_end: Effect[]
  exits: DayExit[]
}
```

`duration_days` 必须等于 `days` 数量，`sequence` 从 1 连续递增；运行时不得假设其值为 7。

```text
Scene {
  id: string
  entry_conditions: Condition[]
  threads: Thread[]
  choice_sets: ChoiceSet[]
  on_enter: Effect[]
  exits: SceneExit[]
}

InteractionChoice {
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
}
```

故事日直接持有额度，不再存在 `InteractionStage`。当天所有 `main` 选项共享 `interaction_limit`；提前结束和额度耗尽进入同一日期结算事务。

## 条件与效果

条件联合支持：`all`、`any`、`not`、`flag_equals`、`counter_at_least`、`has_clue`、`has_card`、`encounter_result`、`route_equals`、`route_completed`、`completed_route_count_at_least`、`day_equals`。

效果联合支持：`set_flag`、`increment_counter`、`grant_clue`、`grant_card`、`remove_card`、`reveal_thread`、`change_thread_status`、`start_encounter`、`resolve_primary_route`、`set_primary_route`、`complete_route`、`advance_day`、`complete_story`。`resolve_primary_route` 取路线计数器最高值；并列时暂停日期结算并要求一次不消耗互动的玩家确认。

效果先整组验证再按数组顺序执行。`complete_route` 必须再次核对故事包声明的全部 `required_clues`，缺少线索时不得执行。出口按数组顺序取第一个满足项；结局出口固定使用 True、Happy、Good、Bad 顺序。

## 战斗实体

```text
CardDefinition {
  id, name, type, cost, rules_text, base_damage,
  effects, keywords, route_scope
}

Encounter {
  id, name,
  player_stability, player_guard, player_influence,
  enemy_stability, enemy_guard, enemy_influence,
  enemy_pattern, reward_choices, victory_effects, defeat_effects
}

CombatState {
  rng_cursor, draw_pile, hand, discard_pile,
  player_stats, enemy_stats, bandwidth,
  statuses, round, enemy_intent
}
```

基础伤害加攻击方影响力，再由目标防护吸收。基础目标手牌为 3；正负效果通过 `hand_size_modifiers` 改变本轮目标值。完整动作结算前禁止存档。

## 存档

```text
StoryRun {
  story_id, run_seed, content_version,
  current_day_id, current_day_index, daily_interactions_used,
  route_progress, completed_routes, primary_route,
  clues, deck, forum_state, combat_checkpoint, completed_ending
}

SaveEnvelope {
  schema_version, content_version, revision, updated_at,
  settings, current_run, permanent_archive
}
```

服务端把 payload 作为 JSON 保存，并单独存用户 ID、版本、修订、更新时间和安全摘要；服务端不裁定剧情结果。

## YAML 约束

- 非本地化故事清单位于 `docs/scripts/h5-incident/package.yaml`，声明周期长度、日期顺序、路线条件和结局优先级。
- 路径固定为 `docs/scripts/h5-incident/day-NN-<lang>.yaml`。
- 顶层键顺序为 `meta`、`accounts`、`clues`、`cards`、`encounters`、`scenes`。
- 时间戳使用无年份日期字符串与独立排序序号。
- 多行正文使用 `|-`，引用使用稳定 ID。
- 中英文件除本地化字符串外结构完全相同。

游戏设计与世界观内容采用 CC BY-SA 4.0 许可。
