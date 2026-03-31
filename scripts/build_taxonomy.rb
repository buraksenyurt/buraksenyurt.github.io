# frozen_string_literal: true

require 'json'
require 'yaml'
require 'time'
require 'fileutils'
require 'cgi'

ROOT = File.expand_path('..', __dir__)
POSTS_DIR = File.join(ROOT, '_posts')
OUTPUT_DIR = File.join(ROOT, '_data')
OUTPUT_PATH = File.join(OUTPUT_DIR, 'inferred_taxonomy.json')
GENERATED_PAGES_DIR = File.join(ROOT, 'generated-pages')
CATEGORY_PAGES_DIR = File.join(GENERATED_PAGES_DIR, 'kategoriler')

CATEGORY_ALIASES = {
  '.net' => '.NET',
  'ado-net' => 'Veri Erisimi',
  'ado.net' => 'Veri Erisimi',
  'algoritmalar' => 'Algoritmalar',
  'asp.net' => 'ASP.NET',
  'aspnet-2-0' => 'ASP.NET',
  'aspnet' => 'ASP.NET',
  'bulut' => 'Bulut',
  'c#' => 'C#',
  'csharp' => 'C#',
  'docker' => 'Docker',
  'dotnet-core' => '.NET',
  'entity-framework' => 'Veri Erisimi',
  'go' => 'Go',
  'golang' => 'Go',
  'javascript' => 'JavaScript',
  'kubernetes' => 'Kubernetes',
  'linux' => 'Linux',
  'mikroservisler' => 'Mikroservisler',
  'node.js' => 'Node.js',
  'nodejs' => 'Node.js',
  'oyun programlama' => 'Oyun Programlama',
  'python' => 'Python',
  'raspberry pi' => 'Raspberry Pi',
  'ruby' => 'Ruby',
  'rust' => 'Rust',
  'sql' => 'SQL',
  'tasarim desenleri' => 'Tasarim Desenleri',
  'typescript' => 'TypeScript',
  'veri erisimi' => 'Veri Erisimi',
  'wcf' => 'WCF',
  'wpf' => 'WPF',
  'yapay zeka' => 'Yapay Zeka',
  'zig' => 'Zig'
}.freeze

TAG_ALIASES = {
  '.net' => 'dotnet',
  'ado.net' => 'ado-net',
  'asp.net' => 'aspnet',
  'aspnet' => 'aspnet',
  'c#' => 'csharp',
  'csharp' => 'csharp',
  'entity framework' => 'entity-framework',
  'game dev' => 'game-dev',
  'game development' => 'game-dev',
  'microservices' => 'microservices',
  'node.js' => 'nodejs',
  'nodejs' => 'nodejs',
  'raspberry pi' => 'raspberry-pi',
  'rest api' => 'rest',
  'sql server' => 'sql-server',
  'stored procedure' => 'stored-procedure',
  'tasarim desenleri' => 'design-patterns',
  'web api' => 'web-api',
  'web assembly' => 'webassembly'
}.freeze

CATEGORY_RULES = [
  ['Rust', [/\brust\b/i, /\bcargo\b/i, /\bcrate\b/i, /ownership/i, /borrow(?:ing| checker)/i, /lifetime/i]],
  ['.NET', [/\.net\b/i, /\bdotnet\b/i, /\bc#\b/i, /\bcsharp\b/i, /entity framework/i, /\bblazor\b/i, /linq/i]],
  ['ASP.NET', [/asp\.net/i, /web forms/i, /razor/i, /\bblazor\b/i]],
  ['WCF', [/\bwcf\b/i, /windows communication foundation/i]],
  ['WPF', [/\bwpf\b/i, /\bxbap\b/i, /\bxaml\b/i]],
  ['SQL', [/sql server/i, /stored procedure/i, /\bsqldatareader\b/i, /\bsql\b/i, /\boledb/i, /\bpostgresql\b/i, /\bmysql\b/i]],
  ['Veri Erisimi', [/ado\.net/i, /\bdataset\b/i, /\bdatatable\b/i, /\bsqldatareader\b/i, /\boledb/i, /\bdataadapter\b/i, /entity framework/i, /\bdapper\b/i]],
  ['JavaScript', [/\bjavascript\b/i, /\breact\b/i, /\bangular\b/i, /\bvue\b/i, /\bsocket\.io\b/i, /\bnpm\b/i]],
  ['TypeScript', [/\btypescript\b/i]],
  ['Node.js', [/\bnode\.?js\b/i, /\bfastify\b/i, /\bexpress\b/i, /\bsocket\.io\b/i]],
  ['Python', [/\bpython\b/i, /\bdjango\b/i, /\bflask\b/i]],
  ['Ruby', [/\bruby\b/i, /\brails\b/i, /\bsinatra\b/i]],
  ['Go', [/\bgolang\b/i, /go programlama/i, /go dili/i]],
  ['Zig', [/\bzig\b/i]],
  ['Docker', [/\bdocker\b/i, /docker-compose/i, /\bcontainer\b/i]],
  ['Kubernetes', [/\bkubernetes\b/i, /\bk8s\b/i]],
  ['Raspberry Pi', [/raspberry pi/i, /\braspi\b/i]],
  ['Algoritmalar', [/algoritma/i, /floyd-warshall/i, /dijkstra/i, /\belo\b/i, /satranc/i]],
  ['Tasarim Desenleri', [/tasarim desen/i, /design pattern/i, /singleton/i, /factory/i, /strategy/i, /observer/i, /prototype/i, /memento/i, /proxy/i]],
  ['Oyun Programlama', [/\boyun\b/i, /game dev/i, /flappy bird/i, /dungeon crawl/i, /pack-man/i]],
  ['Bulut', [/\bazure\b/i, /\baws\b/i, /google cloud/i, /\bgcp\b/i, /\bcloud\b/i]],
  ['Mikroservisler', [/microservice/i, /mikroservis/i, /service mesh/i]],
  ['Yapay Zeka', [/yapay zeka/i, /\bllm\b/i, /openai/i, /copilot/i, /machine learning/i, /\bmcp server\b/i]],
  ['Linux', [/\blinux\b/i, /\bubuntu\b/i]]
].freeze

CURATED_CATEGORIES = (CATEGORY_RULES.map(&:first) + CATEGORY_ALIASES.values).uniq.freeze

TAG_RULES = [
  ['rust', [/\brust\b/i]],
  ['cargo', [/\bcargo\b/i]],
  ['ownership', [/ownership/i, /sahiplenme/i]],
  ['borrowing', [/borrow(?:ing| checker)/i, /odunc/i]],
  ['lifetimes', [/lifetime/i, /yasam sure/i]],
  ['wasm', [/\bwasm\b/i]],
  ['webassembly', [/webassembly/i, /web assembly/i]],
  ['web-api', [/web api/i]],
  ['rest', [/\brest\b/i, /restful/i]],
  ['http', [/\bhttp\b/i]],
  ['blazor', [/\bblazor\b/i]],
  ['dotnet', [/\.net\b/i, /\bdotnet\b/i]],
  ['csharp', [/\bc#\b/i, /\bcsharp\b/i]],
  ['aspnet', [/asp\.net/i]],
  ['wcf', [/\bwcf\b/i]],
  ['wpf', [/\bwpf\b/i, /\bxbap\b/i, /\bxaml\b/i]],
  ['sql-server', [/sql server/i, /stored procedure/i]],
  ['stored-procedure', [/stored procedure/i]],
  ['ado-net', [/ado\.net/i]],
  ['entity-framework', [/entity framework/i]],
  ['dataset', [/\bdataset\b/i]],
  ['datatable', [/\bdatatable\b/i]],
  ['sqldatareader', [/\bsqldatareader\b/i]],
  ['docker', [/\bdocker\b/i]],
  ['kubernetes', [/\bkubernetes\b/i, /\bk8s\b/i]],
  ['raspberry-pi', [/raspberry pi/i, /\braspi\b/i]],
  ['javascript', [/\bjavascript\b/i]],
  ['nodejs', [/\bnode\.?js\b/i, /\bfastify\b/i, /\bexpress\b/i]],
  ['react', [/\breact\b/i]],
  ['angular', [/\bangular\b/i]],
  ['python', [/\bpython\b/i]],
  ['ruby', [/\bruby\b/i]],
  ['zig', [/\bzig\b/i]],
  ['go', [/\bgolang\b/i, /go programlama/i, /go dili/i]],
  ['algorithms', [/algoritma/i, /floyd-warshall/i, /dijkstra/i, /\belo\b/i]],
  ['design-patterns', [/tasarim desen/i, /design pattern/i, /singleton/i, /factory/i, /strategy/i, /observer/i, /prototype/i, /memento/i, /proxy/i]],
  ['multithreading', [/multithread/i, /thread\b/i]],
  ['web-service', [/web service/i]],
  ['azure', [/\bazure\b/i]],
  ['gcp', [/google cloud/i, /\bgcp\b/i]],
  ['linux', [/\blinux\b/i, /\bubuntu\b/i]],
  ['microservices', [/microservice/i, /mikroservis/i]],
  ['mcp', [/\bmcp server\b/i, /model context protocol/i]],
  ['ai', [/yapay zeka/i, /\bllm\b/i, /openai/i, /copilot/i]],
  ['game-dev', [/\boyun\b/i, /game dev/i, /flappy bird/i, /dungeon crawl/i, /pack-man/i]]
].freeze

def normalize_key(value)
  value.to_s.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
       .downcase
       .tr('çğıöşü', 'cgiosu')
       .gsub(/[^a-z0-9.+#\s-]/, ' ')
       .gsub(/\s+/, ' ')
       .strip
end

def canonical_category(name)
  value = name.to_s.strip
  return nil if value.empty?

  alias_hit = CATEGORY_ALIASES[normalize_key(value)]
  return alias_hit if alias_hit

  value
end

def canonical_tag(name)
  value = name.to_s.strip
  return nil if value.empty?

  alias_hit = TAG_ALIASES[normalize_key(value)]
  return alias_hit if alias_hit

  normalize_key(value).tr(' ', '-')
end

def extract_post(raw)
  content = raw.sub(/^\uFEFF/, '')
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n?/m)
  raise 'Missing front matter' unless match

  front_matter = YAML.safe_load(match[1], permitted_classes: [Time, Date], aliases: true) || {}
  body = content[match[0].length..] || ''
  [front_matter, body]
end

def infer_values(text, rules)
  rules.each_with_object([]) do |(name, patterns), matches|
    matches << name if patterns.any? { |pattern| text.match?(pattern) }
  end
end

def merge_unique(*lists)
  lists.flatten.compact.each_with_object([]) do |item, merged|
    merged << item unless merged.include?(item)
  end
end

def slugify_segment(value)
  normalize_key(value).tr('.+', '  ').gsub(/[^a-z0-9\s-]/, ' ').gsub(/\s+/, '-').gsub(/-+/, '-').gsub(/^-|-$/, '')
end

def parse_post_filename(path)
  file_name = File.basename(path, File.extname(path))
  match = file_name.match(/\A(\d{4})-(\d{2})-(\d{2})-(.+)\z/)
  raise "Invalid post filename format: #{file_name}. Expected YYYY-MM-DD-kebab-case.md" unless match

  year, month, day, slug = match.captures

  unless slug.match?(/\A[a-z0-9-]+\z/)
    raise <<~ERROR.strip
      Invalid post slug in #{file_name}. Use only lowercase ASCII letters, digits, and hyphens in _posts filenames.
      Example: #{year}-#{month}-#{day}-ornek-makale-basligi.md
    ERROR
  end

  [year, month, day, slug]
end

def post_url_for(path)
  year, month, day, slug = parse_post_filename(path)
  encoded_slug = CGI.escape(slug).gsub('+', '%20')
  "/#{year}/#{month}/#{day}/#{encoded_slug}/"
end

def parsed_date(value, path)
  return value.iso8601 if value.respond_to?(:iso8601)

  year, month, day, = parse_post_filename(path)
  Time.utc(year.to_i, month.to_i, day.to_i).iso8601
end

posts = {}

Dir.glob(File.join(POSTS_DIR, '*.md')).sort.each do |path|
  front_matter, body = extract_post(File.read(path, mode: 'r:bom|utf-8'))
  url = post_url_for(path)
  title = front_matter['title'].to_s.strip
  text = [title, body].join("\n").encode('UTF-8', invalid: :replace, undef: :replace, replace: '')

  explicit_categories = Array(front_matter['categories']).compact.map { |item| canonical_category(item) }.compact
  explicit_tags = Array(front_matter['tags']).compact.map { |item| canonical_tag(item) }.compact

  inferred_categories = infer_values(text, CATEGORY_RULES)
  inferred_tags = infer_values(text, TAG_RULES)

  explicit_tags.each do |tag|
    inferred_tags << tag unless inferred_tags.include?(tag)
  end

  explicit_categories.each do |category|
    inferred_categories << category unless inferred_categories.include?(category)
  end

  if inferred_tags.include?('rust')
    inferred_categories << 'Rust' unless inferred_categories.include?('Rust')
  end

  if inferred_tags.include?('dotnet') || inferred_tags.include?('csharp')
    inferred_categories << '.NET' unless inferred_categories.include?('.NET')
  end

  if inferred_tags.include?('sql-server') || inferred_tags.include?('ado-net') || inferred_tags.include?('entity-framework')
    inferred_categories << 'Veri Erisimi' unless inferred_categories.include?('Veri Erisimi')
    inferred_categories << 'SQL' unless inferred_categories.include?('SQL')
  end

  categories = if explicit_categories.any?
                 explicit_categories
               else
                 inferred_categories.first(3)
               end
  tags = merge_unique(explicit_tags, inferred_tags).sort

  posts[url] = {
    'title' => title,
    'date' => parsed_date(front_matter['date'], path),
    'categories' => categories,
    'tags' => tags
  }
end

categories_index = Hash.new { |hash, key| hash[key] = [] }
tags_index = Hash.new { |hash, key| hash[key] = [] }

posts.each do |url, entry|
  summary = {
    'url' => url,
    'title' => entry['title'],
    'date' => entry['date']
  }

  entry['categories'].each { |category| categories_index[category] << summary }
  entry['tags'].each { |tag| tags_index[tag] << summary }
end

sort_posts = lambda do |items|
  items.sort_by { |item| [-Time.parse(item['date']).to_i, item['title']] }
end

categories_index.transform_values!(&sort_posts)
tags_index.transform_values!(&sort_posts)

tag_counts = tags_index.transform_values(&:size)
min_count = tag_counts.values.min || 0
max_count = tag_counts.values.max || 0

tag_cloud = tag_counts.select { |_name, count| count >= 20 }.sort_by { |name, _count| name }.map do |name, count|
  weight = if max_count == min_count
             3
           else
             1 + (((count - min_count) * 4.0) / (max_count - min_count)).round
           end

  {
    'name' => name,
    'count' => count,
    'weight' => weight
  }
end

payload = {
  'generated_at' => Time.now.utc.iso8601,
  'posts' => posts,
  'categories' => categories_index.sort.to_h,
  'tags' => tags_index.sort.to_h,
  'tag_cloud' => tag_cloud
}

FileUtils.rm_rf(CATEGORY_PAGES_DIR)

categories_index.each do |category_name, category_posts|
  per_page = 20
  total_pages = [(category_posts.size.to_f / per_page).ceil, 1].max
  category_slug = slugify_segment(category_name)
  base_permalink = "/kategoriler/#{category_slug}/"

  (1..total_pages).each do |page_number|
    page_dir = if page_number == 1
                 File.join(CATEGORY_PAGES_DIR, category_slug)
               else
                 File.join(CATEGORY_PAGES_DIR, category_slug, 'sayfa', page_number.to_s)
               end
    FileUtils.mkdir_p(page_dir)

    front_matter = {
      'layout' => 'category-archive',
      'title' => category_name,
      'permalink' => page_number == 1 ? base_permalink : "#{base_permalink}sayfa/#{page_number}/",
      'category_name' => category_name,
      'base_permalink' => base_permalink,
      'page_number' => page_number,
      'total_pages' => total_pages,
      'published' => true
    }

    page_content = [
      '---',
      front_matter.to_yaml.sub(/\A---\s*\n?/, '').sub(/\n?\.\.\.\s*\n?\z/, '').strip,
      '---',
      ''
    ].join("\n")

    File.write(File.join(page_dir, 'index.md'), page_content)
  end
end

FileUtils.mkdir_p(OUTPUT_DIR)
File.write(OUTPUT_PATH, JSON.pretty_generate(payload))

puts "Wrote #{OUTPUT_PATH} with #{posts.size} posts, #{categories_index.size} categories and #{tags_index.size} tags."