#!/bin/bash

echo "🚀 开始配置 Git 环境..."

# 1. 生成 GitHub 密钥
echo "🔑 1. 正在 ~/.ssh 目录下生成 GitHub 密钥..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

KEY_FILE="$HOME/.ssh/github"
if [ ! -f "$KEY_FILE" ]; then
  ssh-keygen -t ed25519 -C "aubreyhan@live.com" -f "$KEY_FILE" -N ""
  echo "✅ 密钥已成功生成: $KEY_FILE"
else
  echo "⚠️ 密钥 $KEY_FILE 已存在，跳过生成步骤。"
fi

# 2. 配置 ~/.ssh/config 文件
echo "📝 2. 配置 ~/.ssh/config 文件的 host 信息..."
CONFIG_FILE="$HOME/.ssh/config"
touch "$CONFIG_FILE"
chmod 600 "$CONFIG_FILE"

if ! grep -q "Host github.com" "$CONFIG_FILE"; then
  echo "" >> "$CONFIG_FILE"
  echo "Host github.com" >> "$CONFIG_FILE"
  echo "  HostName github.com" >> "$CONFIG_FILE"
  echo "  User git" >> "$CONFIG_FILE"
  echo "  IdentityFile ~/.ssh/github" >> "$CONFIG_FILE"
  echo "✅ 已添加 github.com 的 Host 配置"
else
  echo "⚠️ ~/.ssh/config 中已存在 github.com 配置，跳过添加。"
fi

# 3. 设置全局 Git 用户名和邮箱
echo "👤 3. 设置全局 Git 用户名和邮箱..."
git config --global user.name "Aubrey Han"
git config --global user.email "aubreyhan@live.com"
echo "✅ 全局用户名设为: $(git config --global user.name)"
echo "✅ 全局邮箱设为: $(git config --global user.email)"

# 4. 测试配置是否正常生效
echo "🧪 4. 测试 GitHub SSH 连接..."
echo "注意: 在测试成功前，您必须先将生成的公钥添加到 GitHub 账号中！"
echo ""
echo "---------- 您的公钥内容如下 ----------"
cat "${KEY_FILE}.pub"
echo "--------------------------------------"
echo ""
echo "👉 请前往 https://github.com/settings/keys 添加此公钥"
echo "正在尝试连接 GitHub..."

# ssh -T git@github.com 遇到新 host 时会自动接收（Accept-new）以避免卡住交互
ssh -o StrictHostKeyChecking=accept-new -T git@github.com

if [ $? -eq 1 ]; then
    echo "✅ SSH 测试连接成功 (正常情况下会返回 hi 消息并以状态码 1 退出)"
elif [ $? -eq 0 ]; then
    echo "✅ SSH 测试连接成功"
else
    echo "❌ SSH 测试连接失败，请确认您是否已将公钥添加到 GitHub！"
fi

echo "🎉 脚本执行完毕！"
