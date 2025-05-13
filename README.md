# pgstac GitHub Action

This GitHub Action provides a simple way to run a [pgstac](https://github.com/stac-utils/pgstac) server (with [pypgstac](https://github.com/stac-utils/pgstac/tree/main/pypgstac)) in a Docker container and load STAC data into it as part of your CI/CD workflow.

## Features

- Pulls and runs the official `ghcr.io/stac-utils/pgstac` Docker image
- Waits for the database to be ready
- Runs `pypgstac migrate` to initialize the database
- Loads all STAC collections and items from a specified directory using `pypgstac load`
- Can be reused in any workflow

## Inputs

| Name           | Description                        | Required | Default    |
|----------------|------------------------------------|----------|------------|
| db_password    | PostgreSQL password                | Yes      |            |
| stac_data_dir  | Path to directory with STAC data   | Yes      |            |
| db_port        | Host port for PostgreSQL           | No       | 5439       |

## Usage

1. **Add the action to your repo**  
   Place the action in `.github/workflows/pgstac-action.yml`.

2. **Reference it in your workflow:**

    ```yaml
    - name: Run pgstac and load STAC data
      uses: ./.github/workflows/pgstac-action
      with:
        db_password: ${{ secrets.DatabasePassword || 'postgres' }}
        stac_data_dir: ${{ github.workspace }}/tests/data
        db_port: 5439
    ```

3. **Place your STAC JSON files** (collections and items) in the directory you specify as `stac_data_dir`.

## How it Works

- The action starts a `pgstac` Docker container with the provided credentials.
- It waits until the database is ready to accept connections.
- It runs `pypgstac migrate` to set up the schema.
- It loads all `.json` files in the data directory as collections or items, based on their `"type"` field.

## Example Directory Structure

```text
.github/
  workflows/
    pgstac-action/
      pgstac-action.yml
tests/
  data/
    stac-collection.json
    stac-item.json
.github/workflows/
  main.yml
```

## Notes

- The action uses `--network host` for Docker commands, which works on GitHub-hosted Linux runners.
- Make sure your STAC files are valid and in the correct directory.
- You can customize the loading logic in the composite action as needed.

## License

MIT
