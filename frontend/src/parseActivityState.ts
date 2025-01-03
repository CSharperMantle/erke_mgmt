export default function parseActivityState(v: number) {
  switch (v) {
    case 0:
      return "未开放签到"
    case 1:
      return "已开放签到"
    case 2:
      return "已开放签退"
    case 3:
      return "完结已审核"
    default:
      return "?"
  }
}
