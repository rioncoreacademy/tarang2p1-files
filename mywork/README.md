# mywork/ — Your Personal Lab Files

Save your own Verilog designs here, directly as encrypted files.

## How it works

1. Open a new filename ending in `.v.enc` here in gvim — it doesn't need to
   exist yet
2. Write your design and save with `:w` — gvim encrypts the buffer straight
   to that file (see `tools/tarang2-dp1-crypt.vim`)
3. Commit and push the `.enc` file to save your work to GitHub

Plaintext is never written to disk at any point — gvim decrypts/encrypts
entirely in its own memory buffer.

## Example

```bash
cd ~/lab/mywork
gvim my_adder.v.enc     # new filename — :w creates it, encrypted, in place

# Commit and push from ~/lab/
cd ~/lab
git add mywork/my_adder.v.enc
git commit -m "my adder design"
git push
```

To compile/simulate: `cd ~/lab && make` — this briefly decrypts into
`~/lab/build/` (RAM only) just long enough for `iverilog` to compile, then
shreds the plaintext immediately.

## Notes

- Only `.enc` files can be committed — plain `.v` files are blocked
- Your designs only exist as plaintext inside gvim's buffer while you're
  editing, or in `~/lab/build/` for the few seconds a `make` compile takes
- To restore your work: clone/pull this repo and open the `.enc` files in
  gvim — no separate decrypt step needed
