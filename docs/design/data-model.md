# 内容与运行时数据模型

## 内容实体

```text
StoryPackage {
  id: string
  content_version: string
  duration_days: integer
  boards: Board[]
  days: StoryDay[]
  endings: Ending[]
}

StoryDay {
  day_id: string
  story_id: string
  sequence: integer
  display_date: string
  locale: zh-CN | en-US
  phases: StoryPhase[]
  summary: DaySummary
  on_end: Effect[]
}

StoryPhase {
  phase_id: string
  sequence: integer
  title: string
  entry_conditions: Condition[]
  threads: Thread[]
  choice_sets: ChoiceSet[]
  direct_messages: DirectMessageThread[]
  on_enter: Effect[]
  on_end: Effect[]
}
```

阶段数量和每阶段帖子数量由剧情声明，不设每日互动额度。

## 互动

```text
InteractionChoice {
  id: string
  action_type: create_post | create_comment | create_reply | react_agree | react_disagree | reply_direct_message
  target_id: string
  title: string | null
  body: string | null
  conditions: Condition[]
  effects: Effect[]
  once: boolean
}
```

## 线索与证物

```text
ClueDefinition {
  id: string
  name: string
  description: string
}

EvidenceDefinition {
  id: string
  name: string
  description: string
  max_confidence: integer
}
```

证物置信度范围为 0–3。私信内容不可转化为证物。

## 私信

```text
DirectMessageThread {
  id: string
  sender_id: string
  participant_ids: string[]
  visibility: private
  trigger_conditions: Condition[]
  arrival: current_phase | next_phase
  messages: DirectMessage[]
  choice_sets: ChoiceSet[]
}

DirectMessage {
  id: string
  author_id: string
  body: string
  timestamp: string
  state: unread | read | replied | expired
}
```

## 条件与效果

条件支持：`all`、`any`、`not`、`flag_equals`、`counter_at_least`、`has_clue`、`evidence_confidence_at_least`、`day_equals`、`private_flag_equals`、`hidden_value_at_least`、`dm_replied`。

效果支持：`set_flag`、`set_private_flag`、`increment_counter`、`increment_hidden_value`、`grant_clue`、`grant_evidence`、`increase_evidence_confidence`、`reveal_thread`、`change_thread_status`、`reveal_direct_message`、`change_dm_state`、`advance_day`、`complete_story`。

## 周目存档

```text
StoryRun {
  story_id
  content_version
  current_day_id
  current_phase_id
  completed_phases
  clues
  evidence_confidence
  hidden_values
  flags
  private_flags
  direct_messages
  ending_path
  completed_ending
}
```
