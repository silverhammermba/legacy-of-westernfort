require 'nokogiri'

# given a file path, find the mod name for that file
def mod_name file
  dir = File.expand_path File.dirname(file)
  loop do
    begin
      File.open(File.join(dir, 'About', 'About.xml')) do |about|
        about_xml = Nokogiri::XML(about)
        name = about_xml.xpath('ModMetaData/name/text()')
        if name.empty?
          return File.basename dir
        else
          return name.text
        end
      end
    rescue
      # no About in this directory, continue to next parent
    end

    next_dir = File.expand_path File.join(dir, '..')
    fail "can't find mod for #{file}" if next_dir == dir
    dir = next_dir
  end
end

# backstory substitutions (nil means I will need to fix it manually)
# TODO: police => militia ?
fixes = {
  /husband/i => 'wife',
  /\bmom\b/i => 'birth mom',
  /\bmother\b/i => 'birth mother',
  /\bfather/i => 'gene mother',
  /\bbrother/i => 'sister',
  /grandfather/i => 'grandmother',
  /\bdad(s?)\b/i => 'mom\1',
  /\bmanly\b/i => 'womanly',
  /male/i => nil,
  /uncle/i => 'aunt',
  /nephew/i => 'niece',
  /\bson(s?)\b/i => 'daughter\1',
  /\bhe\b/i => 'she',
  /\bhim\b/i => 'her',
  /\bhis\b/i => 'hers',
  /\bboy(s?)\b/i => 'girl\1',
  /\bking(s?)\b/i => 'queen\1',
  /\bmaster(s?)\b/i => nil,
  /(?<!wo)men\b/i => 'women',
  /(?<!hu|wo)man\b/i => 'woman',
  /\blord(s?)\b/i => nil,
  /\bemperor(s?)\b/i => nil,
}

need_patch_pattern = Regexp.union *fixes.keys

# def nodes in which the above words might appear
patchable_nodes = ['title', 'titleShort', 'baseDesc']

if ARGV.length < 2
  warn "usage: #$0 OUTPUT [INPUT...]"
  exit 1
end

patch_doc =
  begin
    # try to add to existing patch file. noblanks ensures that new patches get pretty-printed
    Nokogiri::XML(File.open(ARGV[0]), &:noblanks)
  rescue
    Nokogiri::XML::Document.new
  end

patch = (patch_doc.root ||= Nokogiri::XML::Node.new('Patch', patch_doc))

ARGV[1..-1].each do |input|
  # first find which mod it's from
  mod = mod_name(input)

  File.open(input) do |f|
    data = Nokogiri::XML(f)

    data.xpath("Defs/BackstoryDef").each do |backstory|
      name = backstory.at_xpath('defName').content

      patchable_nodes.each do |nodeName|
        node_value = backstory.at_xpath(nodeName).content

        if node_value =~ need_patch_pattern
          patch_xpath = "Defs/BackstoryDef[defName=\"#{name}\"]/#{nodeName}"
          # ensure we don't add duplicate patches
          next unless patch_doc.xpath("//xpath[text()='#{patch_xpath}']").empty?

          op = Nokogiri::XML::Node.new 'Operation', patch_doc
          op['Class'] = 'PatchOperationReplace'
          op.parent = patch

          xpath = Nokogiri::XML::Node.new 'xpath', patch_doc
          xpath.content = patch_xpath
          xpath.parent = op

          value = Nokogiri::XML::Node.new 'value', patch_doc
          value.parent = op

          todo = Nokogiri::XML::Comment.new patch_doc, ' TODO '
          todo.parent = value

          patch_node = Nokogiri::XML::Node.new nodeName, patch_doc
          patch_node.parent = value

          fixed = node_value.dup
          fixes.each do |pattern, replacement|
            next unless replacement
            fixed.gsub!(pattern, replacement)
          end
          patch_node.content = fixed

          original = Nokogiri::XML::Comment.new patch_doc, node_value
          original.parent = value
        end
      end
    end
  end
end

File.open(ARGV[0], ?w) do |f|
  f.write patch_doc.to_xml
end
