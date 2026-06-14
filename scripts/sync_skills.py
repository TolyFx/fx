"""
将各模块内的 skills 同步到根目录 skills/ 汇总目录。

用法：
  python scripts/sync_skills.py

规则：
  - 扫描 modules/{core,ability,kit}/*/skills/ 下的所有 skill 目录
  - 复制到根目录 skills/ 下（同名覆盖）
  - 根目录 skills/ 作为只读汇总，不应手动编辑
"""

import shutil
from pathlib import Path


def sync_skills():
    root = Path(__file__).resolve().parent.parent
    modules_dir = root / 'modules'
    target_dir = root / 'skills'

    if not modules_dir.exists():
        print(f'modules 目录不存在: {modules_dir}')
        return

    target_dir.mkdir(exist_ok=True)

    synced = []

    # 扫描 modules/{layer}/{package}/skills/
    for layer_dir in sorted(modules_dir.iterdir()):
        if not layer_dir.is_dir():
            continue
        for module_dir in sorted(layer_dir.iterdir()):
            skills_dir = module_dir / 'skills'
            if not skills_dir.is_dir():
                continue
            for skill_dir in sorted(skills_dir.iterdir()):
                if not skill_dir.is_dir():
                    continue
                dest = target_dir / skill_dir.name
                if dest.exists():
                    shutil.rmtree(dest)
                shutil.copytree(skill_dir, dest)
                synced.append(
                    f'  {layer_dir.name}/{module_dir.name}/skills/{skill_dir.name} → skills/{skill_dir.name}'
                )

    if synced:
        print(f'同步完成，共 {len(synced)} 个 skill:')
        for line in synced:
            print(line)
    else:
        print('未找到任何 skill 目录。')


if __name__ == '__main__':
    sync_skills()
