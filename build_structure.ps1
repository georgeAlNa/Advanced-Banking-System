$ROOT = "lib"
$CORE = Join-Path $ROOT "core"
$FEATURES = Join-Path $ROOT "features"

# تأكد أن core و features موجودين
if (-not (Test-Path $CORE)) { throw "Folder not found: $CORE" }
if (-not (Test-Path $FEATURES)) { throw "Folder not found: $FEATURES" }

# ---------- CORE ----------
$coreDirs = @("events","logging","security","network","storage","errors") | ForEach-Object { Join-Path $CORE $_ }
$coreDirs | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }

$coreFiles = @(
  "events\event_bus.dart",
  "events\events.dart",
  "logging\audit_logger.dart",
  "security\rbac.dart",
  "network\api_client.dart",
  "storage\secure_storage.dart",
  "errors\app_exception.dart",
  "errors\failure_mapper.dart"
) | ForEach-Object { Join-Path $CORE $_ }
$coreFiles | ForEach-Object { New-Item -ItemType File -Force -Path $_ | Out-Null }

function Ensure-Feature($name) {
  $base = Join-Path $FEATURES $name
  $paths = @(
    "data\models",
    "data\datasources",
    "data\repos",
    "logic\cubit",
    "logic\state",
    "logic\usecases",
    "logic\services",
    "logic\validators\handlers",
    "presentation\screens",
    "presentation\widgets"
  ) | ForEach-Object { Join-Path $base $_ }

  $paths | ForEach-Object { New-Item -ItemType Directory -Force -Path $_ | Out-Null }
}

function Touch([string[]]$paths) {
  $paths | ForEach-Object { New-Item -ItemType File -Force -Path $_ | Out-Null }
}

# ---------- FEATURES ----------
$featureNames = @("login","home","accounts","transfer_money","support","profile")
$featureNames | ForEach-Object { Ensure-Feature $_ }

# ---------- LOGIN ----------
Touch @(
  (Join-Path $FEATURES "login\data\models\auth_token_model.dart"),
  (Join-Path $FEATURES "login\data\models\login_request_model.dart"),
  (Join-Path $FEATURES "login\data\datasources\auth_remote_ds.dart"),
  (Join-Path $FEATURES "login\data\repos\auth_repo_impl.dart"),
  (Join-Path $FEATURES "login\logic\cubit\login_cubit.dart"),
  (Join-Path $FEATURES "login\logic\state\login_state.dart"),
  (Join-Path $FEATURES "login\logic\services\auth_facade.dart"),
  (Join-Path $FEATURES "login\logic\services\auth_strategy.dart"),
  (Join-Path $FEATURES "login\logic\services\password_login_strategy.dart"),
  (Join-Path $FEATURES "login\logic\services\otp_login_strategy.dart"),
  (Join-Path $FEATURES "login\logic\services\biometric_login_strategy.dart"),
  (Join-Path $FEATURES "login\logic\services\auth_repo.dart"),
  (Join-Path $FEATURES "login\logic\validators\login_validator_chain.dart"),
  (Join-Path $FEATURES "login\logic\validators\handlers\email_format_handler.dart"),
  (Join-Path $FEATURES "login\logic\validators\handlers\password_policy_handler.dart"),
  (Join-Path $FEATURES "login\logic\validators\handlers\rate_limit_handler.dart"),
  (Join-Path $FEATURES "login\logic\usecases\login_usecase.dart"),
  (Join-Path $FEATURES "login\presentation\screens\login_screen.dart"),
  (Join-Path $FEATURES "login\presentation\widgets\login_form.dart")
)

# ---------- HOME ----------
Touch @(
  (Join-Path $FEATURES "home\data\models\home_summary_model.dart"),
  (Join-Path $FEATURES "home\data\datasources\home_remote_ds.dart"),
  (Join-Path $FEATURES "home\data\repos\home_repo_impl.dart"),
  (Join-Path $FEATURES "home\logic\cubit\home_cubit.dart"),
  (Join-Path $FEATURES "home\logic\state\home_state.dart"),
  (Join-Path $FEATURES "home\logic\services\home_facade.dart"),
  (Join-Path $FEATURES "home\logic\services\home_event_listener.dart"),
  (Join-Path $FEATURES "home\logic\services\home_repo.dart"),
  (Join-Path $FEATURES "home\presentation\screens\home_screen.dart"),
  (Join-Path $FEATURES "home\presentation\widgets\balances_card.dart"),
  (Join-Path $FEATURES "home\presentation\widgets\recent_transactions_card.dart"),
  (Join-Path $FEATURES "home\presentation\widgets\alerts_card.dart")
)

# ---------- ACCOUNTS ----------
Touch @(
  (Join-Path $FEATURES "accounts\data\models\account_model.dart"),
  (Join-Path $FEATURES "accounts\data\models\account_hierarchy_model.dart"),
  (Join-Path $FEATURES "accounts\data\datasources\accounts_remote_ds.dart"),
  (Join-Path $FEATURES "accounts\data\repos\accounts_repo_impl.dart"),
  (Join-Path $FEATURES "accounts\logic\cubit\accounts_cubit.dart"),
  (Join-Path $FEATURES "accounts\logic\state\accounts_state.dart"),
  (Join-Path $FEATURES "accounts\logic\services\accounts_facade.dart"),
  (Join-Path $FEATURES "accounts\logic\services\account_repo.dart"),
  (Join-Path $FEATURES "accounts\logic\services\account_factory.dart"),
  (Join-Path $FEATURES "accounts\logic\services\account_tree_composite.dart"),
  (Join-Path $FEATURES "accounts\logic\services\account_state_machine.dart"),
  (Join-Path $FEATURES "accounts\logic\usecases\load_accounts_usecase.dart"),
  (Join-Path $FEATURES "accounts\logic\usecases\create_account_command.dart"),
  (Join-Path $FEATURES "accounts\logic\usecases\close_account_command.dart"),
  (Join-Path $FEATURES "accounts\logic\usecases\change_account_state_command.dart"),
  (Join-Path $FEATURES "accounts\presentation\screens\accounts_screen.dart"),
  (Join-Path $FEATURES "accounts\presentation\widgets\account_tile.dart"),
  (Join-Path $FEATURES "accounts\presentation\widgets\account_tree_view.dart"),
  (Join-Path $FEATURES "accounts\presentation\widgets\account_actions_sheet.dart")
)

# ---------- TRANSFER MONEY ----------
New-Item -ItemType Directory -Force -Path (Join-Path $FEATURES "transfer_money\logic\services\fee_decorators") | Out-Null

Touch @(
  (Join-Path $FEATURES "transfer_money\data\models\transfer_request_model.dart"),
  (Join-Path $FEATURES "transfer_money\data\models\transfer_result_model.dart"),
  (Join-Path $FEATURES "transfer_money\data\models\beneficiary_model.dart"),
  (Join-Path $FEATURES "transfer_money\data\datasources\transfer_remote_ds.dart"),
  (Join-Path $FEATURES "transfer_money\data\repos\transfer_repo_impl.dart"),
  (Join-Path $FEATURES "transfer_money\logic\cubit\transfer_cubit.dart"),
  (Join-Path $FEATURES "transfer_money\logic\state\transfer_state.dart"),
  (Join-Path $FEATURES "transfer_money\logic\services\transfer_facade.dart"),
  (Join-Path $FEATURES "transfer_money\logic\services\transfer_repo.dart"),
  (Join-Path $FEATURES "transfer_money\logic\services\transfer_strategy.dart"),
  (Join-Path $FEATURES "transfer_money\logic\services\internal_transfer_strategy.dart"),
  (Join-Path $FEATURES "transfer_money\logic\services\local_transfer_strategy.dart"),
  (Join-Path $FEATURES "transfer_money\logic\services\international_transfer_strategy.dart"),
  (Join-Path $FEATURES "transfer_money\logic\services\fee_decorators\transfer_fee_decorator.dart"),
  (Join-Path $FEATURES "transfer_money\logic\services\fee_decorators\fixed_fee_decorator.dart"),
  (Join-Path $FEATURES "transfer_money\logic\services\fee_decorators\fx_conversion_decorator.dart"),
  (Join-Path $FEATURES "transfer_money\logic\validators\transfer_validator_chain.dart"),
  (Join-Path $FEATURES "transfer_money\logic\validators\handlers\beneficiary_exists_handler.dart"),
  (Join-Path $FEATURES "transfer_money\logic\validators\handlers\sufficient_balance_handler.dart"),
  (Join-Path $FEATURES "transfer_money\logic\validators\handlers\daily_limit_handler.dart"),
  (Join-Path $FEATURES "transfer_money\logic\validators\handlers\fraud_rules_handler.dart"),
  (Join-Path $FEATURES "transfer_money\logic\validators\handlers\otp_authorization_handler.dart"),
  (Join-Path $FEATURES "transfer_money\logic\usecases\process_transfer_usecase.dart"),
  (Join-Path $FEATURES "transfer_money\logic\usecases\transfer_command.dart"),
  (Join-Path $FEATURES "transfer_money\presentation\screens\transfer_screen.dart"),
  (Join-Path $FEATURES "transfer_money\presentation\widgets\beneficiary_picker.dart"),
  (Join-Path $FEATURES "transfer_money\presentation\widgets\amount_input.dart"),
  (Join-Path $FEATURES "transfer_money\presentation\widgets\transfer_review_sheet.dart"),
  (Join-Path $FEATURES "transfer_money\presentation\widgets\transfer_result_view.dart")
)

# ---------- SUPPORT ----------
Touch @(
  (Join-Path $FEATURES "support\data\models\ticket_model.dart"),
  (Join-Path $FEATURES "support\data\models\message_model.dart"),
  (Join-Path $FEATURES "support\data\datasources\support_remote_ds.dart"),
  (Join-Path $FEATURES "support\data\repos\support_repo_impl.dart"),
  (Join-Path $FEATURES "support\logic\cubit\support_cubit.dart"),
  (Join-Path $FEATURES "support\logic\state\support_state.dart"),
  (Join-Path $FEATURES "support\logic\services\support_facade.dart"),
  (Join-Path $FEATURES "support\logic\services\support_repo.dart"),
  (Join-Path $FEATURES "support\logic\services\ticket_state_machine.dart"),
  (Join-Path $FEATURES "support\logic\services\ticket_routing_chain.dart"),
  (Join-Path $FEATURES "support\logic\validators\handlers\route_by_category_handler.dart"),
  (Join-Path $FEATURES "support\logic\validators\handlers\route_by_priority_handler.dart"),
  (Join-Path $FEATURES "support\logic\validators\handlers\route_by_sla_handler.dart"),
  (Join-Path $FEATURES "support\presentation\screens\support_screen.dart"),
  (Join-Path $FEATURES "support\presentation\widgets\ticket_list.dart"),
  (Join-Path $FEATURES "support\presentation\widgets\ticket_chat_view.dart"),
  (Join-Path $FEATURES "support\presentation\widgets\new_ticket_form.dart")
)

# ---------- PROFILE ----------
Touch @(
  (Join-Path $FEATURES "profile\data\models\profile_model.dart"),
  (Join-Path $FEATURES "profile\data\models\settings_model.dart"),
  (Join-Path $FEATURES "profile\data\datasources\profile_remote_ds.dart"),
  (Join-Path $FEATURES "profile\data\repos\profile_repo_impl.dart"),
  (Join-Path $FEATURES "profile\logic\cubit\profile_cubit.dart"),
  (Join-Path $FEATURES "profile\logic\state\profile_state.dart"),
  (Join-Path $FEATURES "profile\logic\services\profile_facade.dart"),
  (Join-Path $FEATURES "profile\logic\services\profile_repo.dart"),
  (Join-Path $FEATURES "profile\logic\services\settings_builder.dart"),
  (Join-Path $FEATURES "profile\logic\services\security_policy_strategy.dart"),
  (Join-Path $FEATURES "profile\logic\services\strict_security_policy.dart"),
  (Join-Path $FEATURES "profile\logic\services\standard_security_policy.dart"),
  (Join-Path $FEATURES "profile\logic\usecases\load_profile_usecase.dart"),
  (Join-Path $FEATURES "profile\logic\usecases\update_profile_command.dart"),
  (Join-Path $FEATURES "profile\logic\usecases\update_settings_command.dart"),
  (Join-Path $FEATURES "profile\logic\usecases\change_password_command.dart"),
  (Join-Path $FEATURES "profile\presentation\screens\profile_screen.dart"),
  (Join-Path $FEATURES "profile\presentation\widgets\profile_header.dart"),
  (Join-Path $FEATURES "profile\presentation\widgets\settings_form.dart"),
  (Join-Path $FEATURES "profile\presentation\widgets\security_section.dart")
)

Write-Host "✅ Done. Ensured folders/files under: $CORE and $FEATURES"
