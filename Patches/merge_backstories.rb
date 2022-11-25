require 'nokogiri'

# overwrite the patch values in NEW_PATCH with those in OLD_PATCH

if ARGV.length != 2
  warn "usage: #$0 NEW_PATCH OLD_PATCH"
  exit 1
end

new_patch = Nokogiri::XML(File.open(ARGV[0]), &:noblanks)
old_patch = Nokogiri::XML(File.open(ARGV[1]), &:noblanks)

new_patch.xpath("//li").each do |op|
  new_xpath = op.xpath('xpath').text

  ext_xpath = "//xpath[text()='#{new_xpath}']"
  existing = old_patch.at_xpath(ext_xpath)

  if existing
    replacement = existing.next.text

    children = op.children

    todo = children[1]
    value = children[2]

    todo.remove
    value.content = replacement
  end
end

File.open(ARGV[0], ?w) do |f|
  f.write new_patch.to_xml
end
