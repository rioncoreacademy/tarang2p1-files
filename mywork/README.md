# mywork/ — Your Personal Lab Files

Save your own Verilog designs here (in `~/labs/`).

## How it works

1. Create or edit a `.v` file anywhere in `~/labs/`
2. It is **automatically encrypted** to `~/lab/mywork/*.v.enc` on every save
3. Commit and push the `.enc` file to save your work to GitHub

## Example

```bash
# Work in ~/labs/
cd ~/labs
vim my_adder.v          # write your design and save

# Encrypted version appears automatically
ls ~/lab/mywork/        # my_adder.v.enc

# Commit and push from ~/lab/
cd ~/lab
git add mywork/my_adder.v.enc
git commit -m "my adder design"
git push
```

## Notes

- Only `.enc` files can be committed — plain `.v` files are blocked
- Your `.v` files stay in RAM (`~/labs/`) and are never pushed to GitHub
- To restore your work: the `.enc` files are decrypted automatically when you reopen the Codespace
