const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = plugin(function({ matchComponents, theme }) {
  const path = require("path");
  const fs = require("fs");

  const iconsDir = path.join(__dirname, "../../deps/material_icons/svg/400");
  const values = {};

  const styles = [
    ["", "outlined"],
    ["_rounded", "rounded"],
    ["_sharp", "sharp"],
  ];

  styles.forEach(([suffix, dir]) => {
    fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
      let name = path.basename(file, ".svg") + suffix;
      name = name.replaceAll("_", "-");

      values[name] = {
        name,
        fullPath: path.join(iconsDir, dir, file),
      };
    });
  });

  matchComponents({
    "material": ({ name, fullPath }) => {
      let content = fs.readFileSync(fullPath, "utf8").replace(/\r?\n|\r/g, "");
      content = content.replace(' width="48" height="48"', "");

      const size = theme("spacing.6");

      return {
        [`--material-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
        "-webkit-mask": `var(--material-${name})`,
        "mask": `var(--material-${name})`,
        "mask-repeat": "no-repeat",
        "background-color": "currentColor",
        "vertical-align": "middle",
        "display": "inline-block",
        "width": size,
        "height": size,
      };
    }
  }, { values });
})
