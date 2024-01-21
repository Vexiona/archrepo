# Clean up the repo, re-create the DB and the release
# #1: arch
if test -z "$argv[1]"
    set tag aarch64
else
    set tag $argv[1]
end
pushd pkgs/$tag/latest
set files (readlink *)
popd # pkgs/latest
rm -rf releases
mkdir releases
pushd releases
for file in $files
    ln -sf (string replace ../ ../pkgs/$tag/ $file) (string split --right --max 1 --fields 2 '/' $file | string replace ':' '.')
end
repo-add --verify --sign Vexiona-$tag.db.tar.zst *.pkg.tar.zst
sudo rsync --recursive --verbose --copy-links --delete ./ /srv/http/repo/Vexiona/$tag &
gh release delete --yes $tag
gh release create $tag --title $tag --notes "Last full update at $(date)" --latest Vexiona-$tag.{db,files}{,.sig} *.pkg.tar.zst{,.sig}
popd # releases
wait # rsync