export { auctionBuySide } from "./auction-buy-side";
export { auctionSellSide } from "./auction-sell-side";
export { negotiatedBuySide } from "./negotiated-buy-side";
export { negotiatedSellSide } from "./negotiated-sell-side";
export { jvLeadParty } from "./jv-lead-party";
export { jvParticipatingParty } from "./jv-participating-party";

import { auctionBuySide } from "./auction-buy-side";
import { auctionSellSide } from "./auction-sell-side";
import { negotiatedBuySide } from "./negotiated-buy-side";
import { negotiatedSellSide } from "./negotiated-sell-side";
import { jvLeadParty } from "./jv-lead-party";
import { jvParticipatingParty } from "./jv-participating-party";

export const allTemplates = [
  auctionBuySide,
  auctionSellSide,
  negotiatedBuySide,
  negotiatedSellSide,
  jvLeadParty,
  jvParticipatingParty,
];
