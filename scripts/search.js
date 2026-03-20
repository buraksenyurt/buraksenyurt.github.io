document.addEventListener("DOMContentLoaded", () => {
  const input = document.getElementById("site-search-input");
  const results = document.getElementById("search-results");
  const status = document.getElementById("search-status");

  if (!input || !results || !status) {
    return;
  }

  let searchIndex = [];

  const escapeHtml = (value) =>
    value
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/\"/g, "&quot;")
      .replace(/'/g, "&#39;");

  const excerptFor = (post, query) => {
    const normalized = post.content || post.excerpt || "";
    if (!normalized) {
      return "Özet bulunamadı.";
    }

    const lower = normalized.toLowerCase();
    const index = lower.indexOf(query.toLowerCase());
    if (index === -1) {
      return normalized.slice(0, 180).trim() + (normalized.length > 180 ? "..." : "");
    }

    const start = Math.max(0, index - 70);
    const end = Math.min(normalized.length, index + 110);
    const prefix = start > 0 ? "..." : "";
    const suffix = end < normalized.length ? "..." : "";
    return `${prefix}${normalized.slice(start, end).trim()}${suffix}`;
  };

  const render = (matches, query) => {
    if (!query.trim()) {
      results.innerHTML = "";
      status.textContent = "Aramaya başlamak için bir kelime yazın.";
      return;
    }

    if (!matches.length) {
      results.innerHTML = "";
      status.textContent = `“${query}” için sonuç bulunamadı.`;
      return;
    }

    status.textContent = `“${query}” için ${matches.length} sonuç bulundu.`;
    results.innerHTML = matches
      .map((post) => {
        const tags = (post.tags || []).map((tag) => `<span class="search-chip">#${escapeHtml(tag)}</span>`).join("");
        const categories = (post.categories || []).map((category) => `<span class="search-chip">${escapeHtml(category)}</span>`).join("");

        return `
          <article class="search-result-card">
            <div class="search-result-meta">${escapeHtml(post.date || "")}</div>
            <h2 class="search-result-title"><a href="${post.url}">${escapeHtml(post.title)}</a></h2>
            <p class="search-result-excerpt">${escapeHtml(excerptFor(post, query))}</p>
            <div class="search-result-taxonomy">${categories}${tags}</div>
          </article>
        `;
      })
      .join("");
  };

  const score = (post, query) => {
    const terms = query.toLowerCase().split(/\s+/).filter(Boolean);
    const title = (post.title || "").toLowerCase();
    const content = (post.content || "").toLowerCase();
    const tags = (post.tags || []).join(" ").toLowerCase();
    const categories = (post.categories || []).join(" ").toLowerCase();

    return terms.reduce((total, term) => {
      let points = 0;
      if (title.includes(term)) points += 6;
      if (tags.includes(term)) points += 4;
      if (categories.includes(term)) points += 3;
      if (content.includes(term)) points += 1;
      return total + points;
    }, 0);
  };

  const performSearch = () => {
    const query = input.value.trim();
    if (!query) {
      render([], query);
      return;
    }

    const matches = searchIndex
      .map((post) => ({ ...post, _score: score(post, query) }))
      .filter((post) => post._score > 0)
      .sort((left, right) => right._score - left._score)
      .slice(0, 50);

    render(matches, query);
  };

  fetch("/search.json")
    .then((response) => response.json())
    .then((data) => {
      searchIndex = data;
      status.textContent = "İndeks hazır. Arama yapabilirsiniz.";
      input.addEventListener("input", performSearch);
    })
    .catch(() => {
      status.textContent = "Arama indeksi yüklenemedi.";
    });
});