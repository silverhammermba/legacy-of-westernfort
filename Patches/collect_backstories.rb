require 'nokogiri'

data = Nokogiri::XML(File.open(ARGV[0]))

patch_doc =
  begin
    Nokogiri::XML(File.open(ARGV[1]))
  rescue
    Nokogiri::XML::Document.new
  end

patch = (patch_doc.root ||= Nokogiri::XML::Node.new('Patch', patch_doc))

need_patch_pattern = Regexp.union *[/husband/i, /father/i, /male/i, /uncle/i, /nephew/i, /\bson\b/i, /\bhe\b/i, /\bhim\b/i, /\bhis\b/i, /\bboy\b/i]
patchable_nodes = ['title', 'titleShort', 'baseDesc']

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

      patch_node = Nokogiri::XML::Node.new nodeName, patch_doc
      patch_node.content = node_value
      patch_node.parent = value

      original = Nokogiri::XML::Comment.new patch_doc, node_value
      original.parent = value
    end
  end
end

File.open(ARGV[1], ?w) do |f|
  f.write patch_doc.to_xml
end
