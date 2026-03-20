document.addEventListener("DOMContentLoaded", () => {
  const article = document.querySelector(".post-content");
  const tocShell = document.getElementById("post-toc-shell");
  const tocList = document.getElementById("post-toc-list");

  if (!article || !tocShell || !tocList) {
    return;
  }

  const headings = Array.from(article.querySelectorAll("h2, h3"));
  if (!headings.length) {
    return;
  }

  const slugify = (value) =>
    value
      .toLowerCase()
      .trim()
      .replace(/[ç]/g, "c")
      .replace(/[ğ]/g, "g")
      .replace(/[ı]/g, "i")
      .replace(/[ö]/g, "o")
      .replace(/[ş]/g, "s")
      .replace(/[ü]/g, "u")
      .replace(/[^a-z0-9\s-]/g, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-");

  headings.forEach((heading, index) => {
    if (!heading.id) {
      heading.id = `${slugify(heading.textContent) || "bolum"}-${index + 1}`;
    }

    const item = document.createElement("li");
    item.className = heading.tagName.toLowerCase() === "h3" ? "toc-item toc-item-sub" : "toc-item";

    const link = document.createElement("a");
    link.href = `#${heading.id}`;
    link.textContent = heading.textContent;

    item.appendChild(link);
    tocList.appendChild(item);
  });

  tocShell.hidden = false;
});