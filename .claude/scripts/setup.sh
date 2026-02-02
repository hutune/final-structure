#!/bin/bash
# RMN Platform - Development Setup Script

echo "🚀 Setting up RMN Platform development environment..."

# Check prerequisites
echo "📋 Checking prerequisites..."

# Node.js
if command -v node &> /dev/null; then
    echo "✅ Node.js $(node --version)"
else
    echo "❌ Node.js not found. Please install Node.js >= 18"
    exit 1
fi

# Python
if command -v python3 &> /dev/null; then
    echo "✅ Python $(python3 --version)"
else
    echo "❌ Python3 not found. Please install Python >= 3.9"
    exit 1
fi

# Git
if command -v git &> /dev/null; then
    echo "✅ Git $(git --version)"
else
    echo "❌ Git not found. Please install Git"
    exit 1
fi

echo ""
echo "✨ Setup complete! You can now use BMAD commands."
echo ""
echo "Quick start:"
echo "  /bmad-help         - Get help with BMAD"
echo "  /ba-create-brief   - Create product brief"
echo "  /pm-create-prd     - Create PRD"
