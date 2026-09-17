const fs = require('fs');

const files = fs.readFileSync('needs_update.txt', 'utf8').split('\n').filter(f => f.trim() !== '');
let success = 0;

for (const file of files) {
    let content = fs.readFileSync(file, 'utf8');
    let originalContent = content;

    if (!content.includes('brand_panel.dart')) {
        content = content.replace(/(import 'package:flutter\/material.dart';)/, "$1\nimport 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';\nimport 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';");
    }

    if (content.includes('return Scaffold(')) {
        // Find the exact starting position of `return Scaffold(`
        const index = content.indexOf('return Scaffold(');
        let braceCount = 0;
        let endIndex = -1;
        
        // Find the matching closing parenthesis for Scaffold(
        for (let i = index + 15; i < content.length; i++) {
            if (content[i] === '(') braceCount++;
            if (content[i] === ')') {
                if (braceCount === 0) {
                    endIndex = i;
                    break;
                }
                braceCount--;
            }
        }

        if (endIndex !== -1) {
            // We found the Scaffold bounds.
            let scaffoldContent = content.substring(index, endIndex + 1);
            
            // Remove old backgroundColor
            scaffoldContent = scaffoldContent.replace(/backgroundColor:\s*AppColors\.[a-zA-Z]+,/g, '');
            
            // Rewrite AppBars
            const appBarRegex = /appBar:\s*AppBar\s*\([\s\S]*?title:\s*(?:const\s*)?Text\(['"]([^'"]+)['"][\s\S]*?\),/g;
            scaffoldContent = scaffoldContent.replace(appBarRegex, (match, title) => {
                return `appBar: AppBar(\n          backgroundColor: Colors.transparent,\n          elevation: 0,\n          scrolledUnderElevation: 0,\n          title: const AppBrandTitle(section: '${title}'),\n          centerTitle: true,\n        ),`;
            });
            
            // Wrap in BrandPageBackground
            scaffoldContent = scaffoldContent.replace('return Scaffold(', 'return BrandPageBackground(\n      child: Scaffold(\n        backgroundColor: Colors.transparent,');
            scaffoldContent += ')'; // Close BrandPageBackground

            content = content.substring(0, index) + scaffoldContent + content.substring(endIndex + 1);
            fs.writeFileSync(file, content);
            success++;
        }
    }
}
console.log(`Successfully updated ${success} files.`);
