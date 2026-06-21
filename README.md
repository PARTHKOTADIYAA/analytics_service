# Analytics Service

Customer behavior analytics ingestion API for Sapana Fertilizer, per the
SRS. Receives events from the frontend (product views, searches, cart
actions, purchases, etc.) and writes them to `user_behavior_events` in
the company's existing RDS MySQL instance.

## Structure

This mirrors the pattern used in `homepage_service`:

- `main.tf`, `variables.tf`, `outputs.tf`, `cors.tf` - root Terraform,
  wiring together the modules below.
- `modules/iam` - the Lambda execution role and its policies.
- `modules/lambda` - the Lambda function itself, packaged from `src/app`.
- `modules/apigateway` - the REST API, `/events` resource, and POST method.
- `modules/cors` - the OPTIONS preflight method needed for browser CORS.
- `src/app` - the FastAPI application (`main.py`), wrapped for Lambda via
  Mangum.
- `.github/workflows/deploy.yml` - CI/CD: plan on PRs, apply on merge to
  `main`.

## ⚠️ Open questions before this can be deployed

This scaffold was built from the SRS and from the *folder names* visible
in `homepage_service` - not its actual file contents. Two things should
be checked once you can see those files:

1. Whether `homepage_service` actually uses REST API (v1, what's used
   here) or HTTP API (v2) for API Gateway - this affects `modules/apigateway`
   and `modules/cors` structure.
2. The Terraform state backend (S3 bucket / DynamoDB table), the GitHub
   Actions AWS auth method, and resource naming/tagging conventions -
   all marked `REPLACE_ME` / `TODO` below.

### Database access (from whoever owns the existing RDS instance)
- [ ] RDS endpoint hostname and port
- [ ] Database/schema name to insert this table into
- [ ] Is RDS in a private VPC? If so: VPC ID, private subnet IDs, security
      group ID allowing port 3306 access
- [ ] How are DB credentials stored for other services (Secrets Manager /
      SSM / env var) - follow the same pattern
- [ ] A new MySQL user scoped to INSERT/SELECT only on
      `user_behavior_events`, or temporary admin access to create it

### AWS / Terraform conventions
- [ ] AWS account + region for this service
- [ ] Terraform state backend: S3 bucket, key prefix, DynamoDB lock table
- [ ] Required resource naming convention / mandatory tags
- [ ] Environment strategy (separate accounts vs. tags in one account)

### CI/CD & GitHub
- [ ] GitHub org to create this repo under
- [ ] How GitHub Actions authenticates to AWS (OIDC role ARN or secrets)
- [ ] Branch protection / required reviewers used elsewhere

### Frontend integration
- [ ] Who reviews PRs on the frontend repo
- [ ] Existing convention for calling backend services from the frontend
      (shared API domain/path pattern)
- [ ] Origin(s) to CORS-whitelist (prod + any staging/preview domains)

## Local development

```bash
cd src/app
python -m venv .py_env
source .py_env/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

Then POST a test event:

```bash
curl -X POST http://localhost:8000/events \
  -H "Content-Type: application/json" \
  -d '{"event_type": "product_view", "session_id": "abc123", "product_id": 42}'
```

Note: `db.py` expects `DB_HOST`, `DB_PORT`, `DB_NAME`, and `DB_SECRET_ARN`
to be set as environment variables - set these locally (pointing at a
test DB) before running, or stub out `db.insert_event` for local-only UI
testing.

## Deploying

```bash
cp terraform.tfvars.example terraform.tfvars   # fill in real values, gitignored
terraform init
terraform plan
terraform apply
```

In practice, this should happen via the GitHub Actions workflow rather
than locally, once that's wired up.
