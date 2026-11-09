// Bouwt het "fun" UI-ontwerp van Catch a Storm! in het open Figma-bestand.
// Gebruik: Figma desktop > Plugins > Development > Import plugin from manifest... > kies manifest.json.
// Daarna: Plugins > Development > Catch a Storm UI. Opnieuw draaien vervangt de schermen.

const PAGE_NAME = "UI - Fun ontwerp";
const NAVY = "#1E1442";
const LG = { family: "Luckiest Guy", style: "Regular" };
const FO = { family: "Fredoka One", style: "Regular" };

const hex = (h) => ({ r: parseInt(h.slice(1, 3), 16) / 255, g: parseInt(h.slice(3, 5), 16) / 255, b: parseInt(h.slice(5, 7), 16) / 255 });
const solid = (h, o = 1) => ({ type: "SOLID", color: hex(h), opacity: o });
const vgrad = (a, b) => ({
  type: "GRADIENT_LINEAR",
  gradientTransform: [[0, 1, 0], [-1, 0, 1]],
  gradientStops: [{ position: 0, color: Object.assign(hex(a), { a: 1 }) }, { position: 1, color: Object.assign(hex(b), { a: 1 }) }],
});
const hgrad = (a, b) => ({
  type: "GRADIENT_LINEAR",
  gradientTransform: [[1, 0, 0], [0, 1, 0]],
  gradientStops: [{ position: 0, color: Object.assign(hex(a), { a: 1 }) }, { position: 1, color: Object.assign(hex(b), { a: 1 }) }],
});

function autoLayout(direction, name, itemSpacing) {
  const f = figma.createFrame();
  f.layoutMode = direction;
  f.primaryAxisSizingMode = "AUTO";
  f.counterAxisSizingMode = "AUTO";
  f.name = name;
  f.itemSpacing = itemSpacing || 0;
  f.fills = [];
  f.clipsContent = false;
  return f;
}

function strokeText(t, w) {
  t.strokes = [solid(NAVY)];
  t.strokeWeight = w;
  t.strokeAlign = "OUTSIDE";
}

function text(parent, str, x, y, w, h, size, font, color, sw, align, name) {
  const t = figma.createText();
  t.fontName = font || LG;
  t.fontSize = size;
  t.characters = str;
  t.fills = [solid(color || "#FFFFFF")];
  if (sw === undefined) sw = 3;
  if (sw) strokeText(t, sw);
  t.textAutoResize = "NONE";
  t.resize(w, h);
  t.x = x;
  t.y = y;
  t.textAlignHorizontal = align || "CENTER";
  t.textAlignVertical = "CENTER";
  if (name) t.name = name;
  parent.appendChild(t);
  return t;
}

function rect(parent, name, x, y, w, h, fills, radius, sw) {
  const r = figma.createRectangle();
  r.name = name;
  r.resize(w, h);
  r.x = x;
  r.y = y;
  r.fills = fills;
  r.cornerRadius = radius || 0;
  if (sw) {
    r.strokes = [solid(NAVY)];
    r.strokeWeight = sw;
  }
  parent.appendChild(r);
  return r;
}

// ---------------------------------------------------------------------------
// Componenten
// ---------------------------------------------------------------------------
const SVG_HEAD = 'xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"';
const ICON_SVGS = {
  Munt: `<svg ${SVG_HEAD}><circle cx="12" cy="12" r="10" fill="#FFD23F" stroke="${NAVY}" stroke-width="2"/><circle cx="12" cy="12" r="6.5" fill="#FFB800"/><path d="M12 7.5l1.3 2.7 3 .4-2.2 2.1.5 3-2.6-1.4-2.6 1.4.5-3-2.2-2.1 3-.4z" fill="#FFF3B0"/></svg>`,
  Winkel: `<svg ${SVG_HEAD}><path d="M6.5 7h14l-2 7.5H8.2z" fill="#FFFFFF"/><path d="M2 4h3l2.5 11h11l2.5-8H6.2" fill="none" stroke="${NAVY}" stroke-width="2.4" stroke-linejoin="round" stroke-linecap="round"/><circle cx="9" cy="19.5" r="2" fill="${NAVY}"/><circle cx="17" cy="19.5" r="2" fill="${NAVY}"/></svg>`,
  Rad: `<svg ${SVG_HEAD}><circle cx="12" cy="12" r="10" fill="#FFE14D" stroke="${NAVY}" stroke-width="2"/><path d="M12 12V2.8A9.2 9.2 0 0 1 21.2 12z" fill="#FF4FD8"/><path d="M12 12H2.8A9.2 9.2 0 0 1 12 2.8z" fill="#3EE0FF"/><path d="M12 12v9.2A9.2 9.2 0 0 1 2.8 12z" fill="#7CFF4F"/><circle cx="12" cy="12" r="2.6" fill="#FFFFFF" stroke="${NAVY}" stroke-width="1.6"/></svg>`,
  Cadeau: `<svg ${SVG_HEAD}><rect x="3" y="9" width="18" height="12" rx="2" fill="#FF4FD8" stroke="${NAVY}" stroke-width="2"/><rect x="2" y="6" width="20" height="5" rx="1.5" fill="#FF8AE6" stroke="${NAVY}" stroke-width="2"/><rect x="10.5" y="7" width="3" height="13" fill="#FFE14D"/><path d="M12 6C10 2 6 2.5 7 5.5 7.6 6 12 6 12 6zM12 6c2-4 6-3.5 5-.5-.6.5-5 .5-5 .5z" fill="#FFE14D" stroke="${NAVY}" stroke-width="1.6"/></svg>`,
  Net: `<svg ${SVG_HEAD}><path d="M14 14l7 7" stroke="#8B5A2B" stroke-width="3" stroke-linecap="round"/><circle cx="9" cy="9" r="7" fill="#E8FBFF" stroke="${NAVY}" stroke-width="2"/><path d="M4 9h10M9 4v10M5.5 5.5l7 7M12.5 5.5l-7 7" stroke="#3EE0FF" stroke-width="1"/></svg>`,
  Pot: `<svg ${SVG_HEAD}><rect x="6" y="2.5" width="12" height="4" rx="1.5" fill="#B5793D" stroke="${NAVY}" stroke-width="1.8"/><rect x="4.5" y="6" width="15" height="15.5" rx="4" fill="#BFF3FF" stroke="${NAVY}" stroke-width="2"/><circle cx="12" cy="14" r="4" fill="#FFE14D"/></svg>`,
  Klaver: `<svg ${SVG_HEAD}><circle cx="8.5" cy="8.5" r="4.2" fill="#4CD964" stroke="${NAVY}" stroke-width="1.6"/><circle cx="15.5" cy="8.5" r="4.2" fill="#4CD964" stroke="${NAVY}" stroke-width="1.6"/><circle cx="8.5" cy="15.5" r="4.2" fill="#4CD964" stroke="${NAVY}" stroke-width="1.6"/><circle cx="15.5" cy="15.5" r="4.2" fill="#4CD964" stroke="${NAVY}" stroke-width="1.6"/><circle cx="12" cy="12" r="2" fill="#2E9E45"/></svg>`,
  Bliksem: `<svg ${SVG_HEAD}><path d="M13.5 1.5L4 13.5h6.5L9 22.5l11-13h-6.8z" fill="#FFE14D" stroke="${NAVY}" stroke-width="2" stroke-linejoin="round"/></svg>`,
  Wolk: `<svg ${SVG_HEAD}><path d="M7 19h10.5a4.5 4.5 0 0 0 .6-9 6 6 0 0 0-11.6 1.5A3.8 3.8 0 0 0 7 19z" fill="#FFFFFF" stroke="${NAVY}" stroke-width="2" stroke-linejoin="round"/></svg>`,
  Plank: `<svg ${SVG_HEAD}><rect x="2" y="13" width="20" height="4" rx="1" fill="#C98A4B" stroke="${NAVY}" stroke-width="1.8"/><rect x="4" y="6" width="5" height="7" rx="1.5" fill="#BFF3FF" stroke="${NAVY}" stroke-width="1.5"/><rect x="10.5" y="6" width="5" height="7" rx="1.5" fill="#BFF3FF" stroke="${NAVY}" stroke-width="1.5"/><path d="M19 7v5M16.5 9.5h5" stroke="#2FBF3A" stroke-width="2.4" stroke-linecap="round"/></svg>`,
};

// [boven, onder, lip]
const COLORS = {
  Groen: ["#8CFF5A", "#2FBF3A", "#1E8A2A"],
  Blauw: ["#6FE6FF", "#2A8CFF", "#1B5FC2"],
  Roze: ["#FF8AF0", "#E03CC8", "#A3218F"],
  Geel: ["#FFF07A", "#FFB800", "#C77F00"],
  Oranje: ["#FFB25A", "#FF6A1F", "#C24410"],
  Paars: ["#B58CFF", "#6A3CFF", "#4320B8"],
  Rood: ["#FF7A7A", "#E8304A", "#A81830"],
};

function createComponents(page) {
  const section = figma.createSection();
  section.name = "Fun componenten";
  page.appendChild(section);
  section.x = 0;
  section.y = -900;

  const icons = {};
  let ix = 40;
  for (const name of Object.keys(ICON_SVGS)) {
    const f = figma.createNodeFromSvg(ICON_SVGS[name]);
    const c = figma.createComponent();
    c.name = "Icoon/" + name;
    c.resize(24, 24);
    c.fills = [];
    for (const ch of f.children.slice()) {
      c.appendChild(ch);
      ch.constraints = { horizontal: "SCALE", vertical: "SCALE" };
    }
    f.remove();
    section.appendChild(c);
    c.x = ix;
    c.y = 40;
    ix += 44;
    icons[name] = c;
  }

  let bx = 40;
  for (const cname of Object.keys(COLORS)) {
    const [top, bot, lip] = COLORS[cname];
    const c = figma.createComponent();
    c.name = "Snoepknop/" + cname;
    c.resize(220, 70);
    c.fills = [];
    c.clipsContent = false;
    const l = rect(c, "Lip", 0, 6, 220, 64, [solid(lip)], 20, 3);
    const b = rect(c, "Body", 0, 0, 220, 62, [vgrad(top, bot)], 20, 3);
    const g = rect(c, "Glans", 12, 6, 196, 18, [solid("#FFFFFF", 0.35)], 9);
    const ic = icons.Munt.createInstance();
    ic.name = "Icoon";
    ic.resize(40, 40);
    ic.x = 14;
    ic.y = 11;
    c.appendChild(ic);
    const t = text(c, "KNOP", 60, 7, 150, 52, 30, LG, "#FFFFFF", 3, "CENTER", "Label");
    for (const n of [l, b, g, t]) n.constraints = { horizontal: "STRETCH", vertical: "STRETCH" };
    const tp = c.addComponentProperty("Tekst", "TEXT", "KNOP");
    t.componentPropertyReferences = { characters: tp };
    const ip = c.addComponentProperty("Icoon", "INSTANCE_SWAP", icons.Munt.id);
    const vp = c.addComponentProperty("Toon icoon", "BOOLEAN", true);
    ic.componentPropertyReferences = { mainComponent: ip, visible: vp };
    c.description = `Snoepknop ${cname}: verloop ${top} -> ${bot}, lip ${lip} 6px eronder, rand ${NAVY} 3px, hoeken 20, glans wit 35%. Roblox: Frame (lip) + Frame met UIGradient + UIStroke + UICorner. Tekst Luckiest Guy wit met 3px rand.`;
    section.appendChild(c);
    c.x = bx;
    c.y = 110;
    bx += 250;
  }

  let tx = 40;
  for (const cname of ["Blauw", "Oranje", "Roze", "Groen", "Paars"]) {
    const [top, bot, lip] = COLORS[cname];
    const c = figma.createComponent();
    c.name = "Tegel/" + cname;
    c.resize(84, 92);
    c.fills = [];
    c.clipsContent = false;
    rect(c, "Lip", 0, 8, 84, 84, [solid(lip)], 24, 3);
    rect(c, "Body", 0, 0, 84, 82, [vgrad(top, bot)], 24, 3);
    rect(c, "Glans", 10, 6, 64, 16, [solid("#FFFFFF", 0.35)], 8);
    const ic = icons.Winkel.createInstance();
    ic.name = "Icoon";
    ic.resize(50, 50);
    ic.x = 17;
    ic.y = 6;
    c.appendChild(ic);
    const t = text(c, "SHOP", -6, 56, 96, 26, 20, LG, "#FFFFFF", 2.5, "CENTER", "Label");
    const badge = figma.createFrame();
    badge.name = "Badge";
    badge.resize(30, 30);
    badge.cornerRadius = 15;
    badge.x = 64;
    badge.y = -10;
    badge.fills = [vgrad("#FF6B6B", "#E01E3C")];
    badge.strokes = [solid(NAVY)];
    badge.strokeWeight = 3;
    c.appendChild(badge);
    const bt = text(badge, "!", 0, 0, 30, 30, 20, LG, "#FFFFFF", 0);
    bt.constraints = { horizontal: "STRETCH", vertical: "STRETCH" };
    const tp = c.addComponentProperty("Tekst", "TEXT", "SHOP");
    t.componentPropertyReferences = { characters: tp };
    const ip = c.addComponentProperty("Icoon", "INSTANCE_SWAP", icons.Winkel.id);
    ic.componentPropertyReferences = { mainComponent: ip };
    const bp = c.addComponentProperty("Badge", "BOOLEAN", false);
    badge.componentPropertyReferences = { visible: bp };
    const btp = c.addComponentProperty("Badge tekst", "TEXT", "!");
    bt.componentPropertyReferences = { characters: btp };
    c.description = "Icoon-knop 84x84 voor de zijbalk. Badge = rode bol met ! of een timer. Groot genoeg voor duimen op telefoon.";
    section.appendChild(c);
    c.x = tx;
    c.y = 230;
    tx += 120;
  }

  const toast = figma.createComponent();
  toast.name = "Melding";
  toast.resize(400, 46);
  toast.fills = [];
  toast.clipsContent = false;
  const tb = rect(toast, "Body", 0, 0, 400, 46, [vgrad("#3B2A8F", "#241A63")], 23, 3);
  const bub = figma.createEllipse();
  bub.name = "IcoonBol";
  bub.resize(54, 54);
  bub.x = -8;
  bub.y = -4;
  bub.fills = [vgrad("#FFFFFF", "#D9E8FF")];
  bub.strokes = [solid(NAVY)];
  bub.strokeWeight = 3;
  toast.appendChild(bub);
  const tic = icons.Wolk.createInstance();
  tic.name = "Icoon";
  tic.resize(36, 36);
  tic.x = 1;
  tic.y = 5;
  toast.appendChild(tic);
  const tt = text(toast, "Gevangen: Regenwolkje!", 56, 0, 330, 46, 20, FO, "#FFFFFF", 2, "LEFT", "Tekst");
  tb.constraints = { horizontal: "STRETCH", vertical: "STRETCH" };
  tt.constraints = { horizontal: "STRETCH", vertical: "STRETCH" };
  const ttp = toast.addComponentProperty("Tekst", "TEXT", "Gevangen: Regenwolkje!");
  tt.componentPropertyReferences = { characters: ttp };
  const tip = toast.addComponentProperty("Icoon", "INSTANCE_SWAP", icons.Wolk.id);
  tic.componentPropertyReferences = { mainComponent: tip };
  toast.description = "Melding: paarse pil met icoon-bol die links uitsteekt. Komt binnen met een pop (0 -> 110% -> 100%).";
  section.appendChild(toast);
  toast.x = 700;
  toast.y = 240;

  section.resizeWithoutConstraints(Math.max(bx, 1200) + 40, 360);
  return section;
}

// ---------------------------------------------------------------------------
// Schermen
// ---------------------------------------------------------------------------
let C = {};

function props(inst) {
  const o = {};
  for (const k of Object.keys(inst.componentProperties)) o[k.split("#")[0]] = k;
  return o;
}

function icon(parent, name, x, y, s) {
  const i = C["Icoon/" + name].createInstance();
  i.resize(s, s);
  i.x = x;
  i.y = y;
  parent.appendChild(i);
  return i;
}

function candy(parent, color, label, x, y, w, h, iconName, name, fontSize) {
  const b = C["Snoepknop/" + color].createInstance();
  const p = props(b);
  const set = {};
  set[p["Tekst"]] = label;
  if (iconName) set[p["Icoon"]] = C["Icoon/" + iconName].id;
  else set[p["Toon icoon"]] = false;
  b.setProperties(set);
  b.resize(w, h);
  b.x = x;
  b.y = y;
  b.name = name;
  parent.appendChild(b);
  const lab = b.findOne((n) => n.name === "Label");
  if (fontSize) lab.fontSize = fontSize;
  const s = Math.min(h - 26, 44);
  const ic = b.findOne((n) => n.name === "Icoon");
  if (ic && iconName) {
    ic.resize(s, s);
    ic.y = (h - 8 - s) / 2;
    ic.x = 12;
  }
  if (iconName) {
    lab.x = 16 + s;
    lab.resize(w - lab.x - 10, lab.height);
  } else {
    lab.x = 8;
    lab.resize(w - 16, lab.height);
  }
  return b;
}

function tile(parent, color, label, iconName, x, y, badge, name) {
  const t = C["Tegel/" + color].createInstance();
  const p = props(t);
  const set = {};
  set[p["Tekst"]] = label;
  set[p["Icoon"]] = C["Icoon/" + iconName].id;
  set[p["Badge"]] = !!badge;
  if (badge) set[p["Badge tekst"]] = badge;
  t.setProperties(set);
  t.x = x;
  t.y = y;
  t.name = name;
  parent.appendChild(t);
  if (badge && badge.length > 1) {
    const bd = t.findOne((n) => n.name === "Badge");
    bd.resize(54, 28);
    bd.x = 46;
    const bt = bd.findOne((n) => n.type === "TEXT");
    bt.fontSize = 15;
  }
  return t;
}

function toast(parent, msg, iconName) {
  const t = C["Melding"].createInstance();
  const p = props(t);
  const set = {};
  set[p["Tekst"]] = msg;
  set[p["Icoon"]] = C["Icoon/" + iconName].id;
  t.setProperties(set);
  parent.appendChild(t);
  return t;
}

function background(frame, W, H) {
  frame.fills = [{
    type: "GRADIENT_LINEAR",
    gradientTransform: [[0, 1, 0], [-1, 0, 1]],
    gradientStops: [
      { position: 0, color: { r: 0.36, g: 0.62, b: 0.98, a: 1 } },
      { position: 0.55, color: { r: 0.72, g: 0.88, b: 1, a: 1 } },
      { position: 0.551, color: { r: 0.45, g: 0.75, b: 0.33, a: 1 } },
      { position: 1, color: { r: 0.3, g: 0.58, b: 0.24, a: 1 } },
    ],
  }];
  const world = figma.createFrame();
  world.name = "Spelwereld (alleen sfeer)";
  world.resize(W, H);
  world.fills = [];
  frame.appendChild(world);
  for (const [x, y, s, c] of [[0.62, 0.5, 0.07, "#FFF05A"], [0.78, 0.47, 0.05, "#AABED2"], [0.35, 0.52, 0.045, "#C8F0E6"], [0.9, 0.55, 0.06, "#B45AFF"]]) {
    const e = figma.createEllipse();
    const d = s * H * 1.6;
    e.resize(d, d);
    e.x = x * W;
    e.y = y * H - d / 2;
    e.fills = [solid(c, 0.85)];
    world.appendChild(e);
  }
  world.locked = true;
}

function zones(frame, W, H, phone) {
  const z = figma.createFrame();
  z.name = "Roblox-zones (info)";
  z.resize(W, H);
  z.fills = [];
  frame.appendChild(z);
  rect(z, "Roblox topbar 58px", 0, 0, W, 58, [solid("#000000", 0.3)]);
  if (phone) {
    const j = figma.createEllipse();
    j.name = "Springknop";
    j.resize(110, 110);
    j.x = W - 140;
    j.y = H - 140;
    j.fills = [solid("#FFFFFF", 0.3)];
    z.appendChild(j);
  }
  z.locked = true;
}

function hud(ui, W, H, opts) {
  // Muntenteller
  const cc = figma.createFrame();
  cc.name = "CoinCounter";
  cc.resize(250, 70);
  cc.fills = [];
  cc.clipsContent = false;
  cc.x = W / 2 - 125;
  cc.y = 62;
  ui.appendChild(cc);
  rect(cc, "Lip", 20, 14, 220, 48, [solid("#C77F00")], 24, 3);
  rect(cc, "Body", 20, 8, 220, 48, [vgrad("#FFF07A", "#FFB800")], 24, 3);
  rect(cc, "Glans", 52, 13, 176, 12, [solid("#FFFFFF", 0.4)], 6);
  icon(cc, "Munt", 0, 0, 66).name = "MuntIcoon";
  text(cc, opts.coins || "1.250", 66, 8, 168, 48, 34, LG, "#FFFFFF", 3, "CENTER", "CoinsLabel");
  const tag = figma.createFrame();
  tag.name = "IncomeSticker";
  tag.resize(70, 30);
  tag.cornerRadius = 15;
  tag.fills = [vgrad("#8CFF5A", "#2FBF3A")];
  tag.strokes = [solid(NAVY)];
  tag.strokeWeight = 3;
  cc.appendChild(tag);
  tag.x = 200;
  tag.y = -6;
  tag.rotation = -10;
  text(tag, "+3/s", 0, 0, 70, 30, 17, LG, "#FFFFFF", 2);

  // Info-chips
  const chips = autoLayout("HORIZONTAL", "InfoChips", 8);
  ui.appendChild(chips);
  for (const [ic, label] of opts.chips || [["Net", "Vlindernet"], ["Pot", "Lab 2/10"]]) {
    const c = autoLayout("HORIZONTAL", "Chip " + label, 6);
    c.paddingLeft = 6;
    c.paddingRight = 12;
    c.paddingTop = 3;
    c.paddingBottom = 3;
    c.counterAxisAlignItems = "CENTER";
    c.cornerRadius = 14;
    c.fills = [solid(NAVY, 0.65)];
    chips.appendChild(c);
    const i = C["Icoon/" + ic].createInstance();
    i.resize(22, 22);
    c.appendChild(i);
    const t = figma.createText();
    t.fontName = FO;
    t.fontSize = 15;
    t.characters = label;
    t.fills = [solid("#FFFFFF")];
    c.appendChild(t);
  }
  chips.x = W / 2 - chips.width / 2;
  chips.y = 136;

  // Zijbalk links
  const side = figma.createFrame();
  side.name = "SideBar";
  side.resize(84, 300);
  side.fills = [];
  side.clipsContent = false;
  side.x = 12;
  side.y = 72;
  ui.appendChild(side);
  tile(side, "Blauw", "SHOP", "Winkel", 0, 0, null, "ShopButton");
  tile(side, "Oranje", "RAD", "Rad", 0, 102, opts.wheelReady === false ? null : "!", "WheelButton");
  tile(side, "Roze", "GRATIS", "Cadeau", 0, 204, opts.rewardBadge || "!", "RewardButton");

  // Robux-aanbiedingen rechts
  const right = figma.createFrame();
  right.name = "RobuxBar";
  right.resize(84, 200);
  right.fills = [];
  right.clipsContent = false;
  right.x = W - 96;
  right.y = 72;
  ui.appendChild(right);
  tile(right, "Paars", "2X GELUK", "Klaver", 0, 0, "R$", "LuckBoostButton");
  tile(right, "Groen", "VIP", "Bliksem", 0, 102, null, "VipButton");

  // Meldingen
  const th = autoLayout("VERTICAL", "Meldingen", 10);
  th.counterAxisAlignItems = "CENTER";
  ui.appendChild(th);
  for (const [m, i] of opts.toasts || []) toast(th, m, i);
  th.x = W / 2 - 200;
  th.y = 170;

  // Stormbanner
  if (opts.storm) {
    const sb = figma.createFrame();
    sb.name = "StormBanner";
    sb.resize(380, 64);
    sb.fills = [];
    sb.clipsContent = false;
    ui.appendChild(sb);
    sb.x = W / 2 - 190;
    sb.y = H - 80;
    rect(sb, "Lip", 0, 6, 380, 58, [solid("#4320B8")], 22, 3);
    rect(sb, "Body", 0, 0, 380, 58, [hgrad("#6A3CFF", "#E03CC8")], 22, 3);
    icon(sb, "Bliksem", -14, -8, 52).name = "BliksemL";
    icon(sb, "Bliksem", 342, -8, 52).name = "BliksemR";
    text(sb, "STORM!  0:48", 40, 2, 300, 34, 30, LG, "#FFF07A", 3, "CENTER", "StormTitel");
    text(sb, "5x kans op zeldzaam weer", 40, 32, 300, 22, 15, FO, "#FFFFFF", 2, "CENTER", "StormSub");
  }
}

function panel(ui, W, H, pw, ph, title, name) {
  const p = figma.createFrame();
  p.name = name;
  p.resize(pw, ph);
  p.fills = [];
  p.clipsContent = false;
  ui.appendChild(p);
  p.x = W / 2 - pw / 2;
  p.y = 58 + (H - 58) / 2 - ph / 2 + 8;
  rect(p, "Lip", 0, 8, pw, ph, [solid("#140D33")], 28, 4);
  rect(p, "Body", 0, 0, pw, ph, [vgrad("#4A35B5", "#241A63")], 28, 4);
  rect(p, "Glans", 16, 10, pw - 32, 20, [solid("#FFFFFF", 0.12)], 10);

  const rib = figma.createFrame();
  rib.name = "TitelLint";
  rib.resize(240, 50);
  rib.fills = [];
  rib.clipsContent = false;
  p.appendChild(rib);
  rect(rib, "Lip", 0, 6, 240, 46, [solid("#C77F00")], 16, 3);
  rect(rib, "Body", 0, 0, 240, 46, [vgrad("#FFF07A", "#FFB800")], 16, 3);
  text(rib, title, 0, 2, 240, 44, 30, LG, "#FFFFFF", 3, "CENTER", "Titel");
  rib.x = pw / 2 - 120;
  rib.y = -26;
  rib.rotation = 2;

  const cl = figma.createFrame();
  cl.name = "SluitKnop";
  cl.resize(46, 50);
  cl.fills = [];
  cl.clipsContent = false;
  p.appendChild(cl);
  const l = figma.createEllipse();
  l.resize(46, 46);
  l.y = 4;
  l.fills = [solid("#A81830")];
  l.strokes = [solid(NAVY)];
  l.strokeWeight = 3;
  cl.appendChild(l);
  const b = figma.createEllipse();
  b.resize(46, 46);
  b.fills = [vgrad("#FF7A7A", "#E8304A")];
  b.strokes = [solid(NAVY)];
  b.strokeWeight = 3;
  cl.appendChild(b);
  text(cl, "X", 0, 1, 46, 44, 26, LG, "#FFFFFF", 3);
  cl.x = pw - 30;
  cl.y = -16;
  return p;
}

function shopCard(parent, x, y, w, h, o) {
  const c = figma.createFrame();
  c.name = o.name;
  c.resize(w, h);
  c.fills = [];
  c.clipsContent = false;
  parent.appendChild(c);
  c.x = x;
  c.y = y;
  rect(c, "Body", 0, 0, w, h, [vgrad(o.grad[0], o.grad[1])], 20, 3);
  const halo = figma.createEllipse();
  halo.name = "Gloed";
  halo.resize(84, 84);
  halo.x = w / 2 - 42;
  halo.y = 6;
  halo.fills = [solid("#FFFFFF", 0.55)];
  c.appendChild(halo);
  icon(c, o.icon, w / 2 - 34, 14, 68).name = "Icoon";
  text(c, o.title, 6, 88, w - 12, 26, 20, LG, o.titleColor || NAVY, 0, "CENTER", "Naam");
  text(c, o.desc, 8, 114, w - 16, 34, 13, FO, o.descColor || "#4B4470", 0, "CENTER", "Uitleg");
  candy(c, o.btnColor, o.btnLabel, 10, h - 62, w - 20, 54, o.btnIcon, "KoopKnop", 24);
  if (o.sticker) {
    const s = figma.createFrame();
    s.name = "Sticker";
    s.resize(74, 30);
    s.cornerRadius = 15;
    s.fills = [vgrad("#FFF07A", "#FFB800")];
    s.strokes = [solid(NAVY)];
    s.strokeWeight = 3;
    c.appendChild(s);
    s.x = w - 58;
    s.y = -12;
    s.rotation = -12;
    text(s, o.sticker, 0, 0, 74, 30, 16, LG, "#FFFFFF", 2);
  }
  return c;
}

function wheel(p) {
  const wf = figma.createFrame();
  wf.name = "Wiel";
  wf.resize(250, 250);
  wf.fills = [];
  wf.clipsContent = false;
  p.appendChild(wf);
  wf.x = 26;
  wf.y = 30;
  const rim = figma.createEllipse();
  rim.name = "Rand";
  rim.resize(250, 250);
  rim.fills = [vgrad("#FFF07A", "#FFB800")];
  rim.strokes = [solid(NAVY)];
  rim.strokeWeight = 4;
  wf.appendChild(rim);

  const cols = ["#FFCD3C", "#5AC878", "#FF9628", "#96C8FF", "#28AA5A", "#5078FF", "#E63C5A", "#AA5AFF"];
  const labels = ["MUNTEN", "GELUK", "VEEL!", "HAGEL", "GELUK+", "BLIKSEM", "JACKPOT", "STORM"];
  const cx = 125, cy = 125, R = 108;
  for (let i = 0; i < 8; i++) {
    const seg = figma.createEllipse();
    seg.name = "Vak " + (i + 1) + " " + labels[i];
    seg.resize(R * 2, R * 2);
    seg.x = cx - R;
    seg.y = cy - R;
    const a0 = -Math.PI / 2 - Math.PI / 8 + (i * Math.PI) / 4;
    seg.arcData = { startingAngle: a0, endingAngle: a0 + Math.PI / 4, innerRadius: 0 };
    seg.fills = [solid(cols[i])];
    seg.strokes = [solid(NAVY)];
    seg.strokeWeight = 2.5;
    wf.appendChild(seg);
  }
  for (let i = 0; i < 8; i++) {
    const phi = -Math.PI / 2 + (i * Math.PI) / 4;
    const px = cx + Math.cos(phi) * 66;
    const py = cy + Math.sin(phi) * 66;
    const t = text(wf, labels[i], 0, 0, 76, 22, 15, LG, "#FFFFFF", 2.5, "CENTER", "Label " + labels[i]);
    const co = Math.cos(-phi), si = Math.sin(-phi);
    t.relativeTransform = [[co, si, px - (co * 38 + si * 11)], [-si, co, py - (-si * 38 + co * 11)]];
  }
  for (let i = 0; i < 8; i++) {
    const phi = -Math.PI / 2 - Math.PI / 8 + (i * Math.PI) / 4;
    const d = figma.createEllipse();
    d.name = "Pin";
    d.resize(10, 10);
    d.x = cx + Math.cos(phi) * 117 - 5;
    d.y = cy + Math.sin(phi) * 117 - 5;
    d.fills = [solid("#FFFFFF")];
    d.strokes = [solid(NAVY)];
    d.strokeWeight = 2;
    wf.appendChild(d);
  }
  const hub = figma.createEllipse();
  hub.name = "Midden";
  hub.resize(44, 44);
  hub.x = cx - 22;
  hub.y = cy - 22;
  hub.fills = [vgrad("#FFFFFF", "#D9E8FF")];
  hub.strokes = [solid(NAVY)];
  hub.strokeWeight = 3;
  wf.appendChild(hub);
  icon(wf, "Munt", cx - 15, cy - 15, 30);
  const ptr = figma.createNodeFromSvg(
    `<svg xmlns="http://www.w3.org/2000/svg" width="40" height="44" viewBox="0 0 40 44"><path d="M4 4h32L20 40z" fill="#FF4646" stroke="${NAVY}" stroke-width="4" stroke-linejoin="round"/><path d="M11 9h12L17 22z" fill="#FFFFFF" opacity="0.5"/></svg>`
  );
  ptr.name = "Pijl";
  wf.appendChild(ptr);
  ptr.x = cx - 20;
  ptr.y = -22;
}

function screen(page, name, W, H, x0, y0, k, phone, build) {
  const s = figma.createFrame();
  s.name = name;
  s.resize(W, H);
  s.x = x0;
  s.y = y0;
  s.clipsContent = true;
  page.appendChild(s);
  background(s, W, H);
  const ui = figma.createFrame();
  ui.name = "CatchAStormUI";
  ui.resize(W / k, H / k);
  ui.fills = [];
  ui.clipsContent = false;
  s.appendChild(ui);
  build(ui, W / k, H / k);
  if (k !== 1) ui.rescale(k);
  zones(s, W, H, phone);
  return s;
}

const SCREEN_NAMES = ["FUN Telefoon - HUD", "FUN Telefoon - Winkel", "FUN Telefoon - Rad", "FUN PC - HUD (UIScale 1.4)", "Lees mij (fun)"];

async function main() {
  await Promise.all([figma.loadFontAsync(LG), figma.loadFontAsync(FO), figma.loadFontAsync({ family: "Inter", style: "Regular" })]);

  let page = figma.root.children.find((p) => p.name === PAGE_NAME);
  if (!page) {
    page = figma.createPage();
    page.name = PAGE_NAME;
  }
  await figma.setCurrentPageAsync(page);

  let section = page.children.find((n) => n.type === "SECTION" && n.name === "Fun componenten");
  if (!section) section = createComponents(page);
  for (const n of section.children) if (n.type === "COMPONENT") C[n.name] = n;

  for (const n of page.children.slice()) if (SCREEN_NAMES.indexOf(n.name) >= 0) n.remove();

  const made = [];
  made.push(screen(page, SCREEN_NAMES[0], 844, 390, 0, 0, 1, true, (ui, W, H) =>
    hud(ui, W, H, { toasts: [["Gevangen: Regenwolkje!", "Wolk"], ["Renzo ving een GOUDEN Bliksem!", "Bliksem"]], storm: true })));

  made.push(screen(page, SCREEN_NAMES[1], 844, 390, 944, 0, 1, true, (ui, W, H) => {
    hud(ui, W, H, { rewardBadge: "1:28" });
    rect(ui, "Dimmer", 0, 0, W, H, [solid("#0A0620", 0.45)]);
    const p = panel(ui, W, H, 600, 290, "WINKEL", "ShopPanel");
    shopCard(p, 22, 36, 176, 236, { name: "NetCard", icon: "Net", title: "VISNET", desc: "Vangt Hagelbuien!", btnColor: "Groen", btnLabel: "250", btnIcon: "Munt", grad: ["#FFFFFF", "#DDE8FF"] });
    shopCard(p, 212, 36, 176, 236, { name: "ShelfCard", icon: "Plank", title: "EXTRA PLANK", desc: "+5 plekken voor potten", btnColor: "Groen", btnLabel: "150", btnIcon: "Munt", grad: ["#FFFFFF", "#DDE8FF"] });
    shopCard(p, 402, 36, 176, 236, { name: "LuckCard", icon: "Klaver", title: "2X GELUK", desc: "30 min dubbele kans op zeldzaam", btnColor: "Roze", btnLabel: "R$ 49", grad: ["#FFD6F8", "#FF8AF0"], titleColor: "#7A1069", descColor: "#7A1069", sticker: "TOP!" });
  }));

  made.push(screen(page, SCREEN_NAMES[2], 844, 390, 1888, 0, 1, true, (ui, W, H) => {
    hud(ui, W, H, {});
    rect(ui, "Dimmer", 0, 0, W, H, [solid("#0A0620", 0.45)]);
    const p = panel(ui, W, H, 620, 292, "GRATIS RAD!", "WheelPanel");
    wheel(p);
    text(p, "Elke dag 1 gratis draai!", 300, 44, 300, 30, 20, FO, "#FFFFFF", 2, "CENTER", "Uitleg");
    text(p, "Win munten, geluk of zeldzaam weer", 300, 74, 300, 24, 14, FO, "#C9C0FF", 0, "CENTER", "Uitleg2");
    candy(p, "Groen", "DRAAI!", 320, 112, 260, 84, "Rad", "SpinButton", 44);
    candy(p, "Roze", "NOG 1x  R$ 25", 340, 212, 220, 58, null, "ExtraSpinButton", 24);
  }));

  made.push(screen(page, SCREEN_NAMES[3], 1920, 1080, 0, 520, 1.4, false, (ui, W, H) =>
    hud(ui, W, H, {
      toasts: [["Je won 250 munten!", "Munt"], ["Er komt een storm aan!", "Bliksem"]],
      storm: true,
      chips: [["Net", "Visnet"], ["Pot", "Lab 7/15"], ["Klaver", "Geluk 4:59"]],
      coins: "12.4K",
    })));

  const note = autoLayout("VERTICAL", SCREEN_NAMES[4], 12);
  note.paddingLeft = note.paddingRight = note.paddingTop = note.paddingBottom = 24;
  note.counterAxisSizingMode = "FIXED";
  note.resize(560, 100);
  note.primaryAxisSizingMode = "AUTO";
  note.fills = [solid("#FFF7CC")];
  note.cornerRadius = 12;
  page.appendChild(note);
  note.x = 2020;
  note.y = 520;
  const h = figma.createText();
  h.fontName = LG;
  h.fontSize = 28;
  h.characters = "Fun ontwerp - lees mij";
  note.appendChild(h);
  const b = figma.createText();
  b.fontName = { family: "Inter", style: "Regular" };
  b.fontSize = 15;
  b.lineHeight = { unit: "PERCENT", value: 145 };
  b.characters = [
    "Stijl: snoep-knoppen met verloop, dikke donkere rand (#1E1442), lip eronder (3D-effect) en een glans-streep.",
    "Titels en getallen in Luckiest Guy, kleine tekst in Fredoka One (allebei Roblox-lettertypes).",
    "Telefoon eerst: rad naast de knop zodat het in 390px hoogte past. PC = zelfde layout met UIScale 1.4.",
    "Rechts: plek voor Robux (2x geluk, VIP). Winkel heeft een Robux-kaart. Rad heeft 'nog 1x draaien'.",
    "Wordt een afbeelding in Roblox: iconen, de rad-vakken en de pijl. De rest (verloop, rand, hoeken) kan met code.",
    "Laagnamen (ShopButton, WheelPanel, SpinButton, CoinsLabel...) graag houden.",
  ].join("\n");
  note.appendChild(b);
  b.layoutSizingHorizontal = "FILL";
  b.textAutoResize = "HEIGHT";

  figma.viewport.scrollAndZoomIntoView(made);
}

main()
  .then(() => figma.closePlugin("Catch a Storm UI is klaar!"))
  .catch((e) => figma.closePlugin("Fout: " + (e && e.message ? e.message : e)));
