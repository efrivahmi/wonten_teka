const fs = require('fs');

const files = fs.readFileSync('needs_update.txt', 'utf8').split('\n').filter(f => f.trim() !== '');
let success = 0;
let errors = [];

for (const file of files) {
    try {
        let content = fs.readFileSync(file, 'utf8');
        
        if (!content.includes('brand_panel.dart')) {
            content = content.replace(/(import 'package:flutter\/material.dart';)/, "$1\nimport 'package:wonten_teka_mobile/core/widgets/brand_panel.dart';\nimport 'package:wonten_teka_mobile/core/widgets/app_brand_title.dart';");
        }

        if (content.includes('Scaffold(')) {
            // Find all instances of Scaffold( and wrap them
            let offset = 0;
            let index;
            while ((index = content.indexOf('Scaffold(', offset)) !== -1) {
                // To avoid wrapping inside BrandPageBackground again if it's already done
                if (index > 25 && content.substring(index - 25, index).includes('BrandPageBackground')) {
                    offset = index + 9;
                    continue;
                }
                
                let braceCount = 0;
                let endIndex = -1;
                
                for (let i = index + 8; i < content.length; i++) {
                    if (content[i] === '(') braceCount++;
                    if (content[i] === ')') {
                        braceCount--;
                        if (braceCount === 0) {
                            endIndex = i;
                            break;
                        }
                    }
                }

                if (endIndex !== -1) {
                    let scaffoldContent = content.substring(index, endIndex + 1);
                    
                    scaffoldContent = scaffoldContent.replace(/backgroundColor:\s*AppColors\.[a-zA-Z]+,/g, '');
                    scaffoldContent = scaffoldContent.replace(/backgroundColor:\s*Colors\.[a-zA-Z]+,/g, '');
                    
                    // Replace AppBar if exists
                    // We'll just look for `appBar: AppBar(` and find its boundaries
                    const appBarIndex = scaffoldContent.indexOf('appBar: AppBar(');
                    if (appBarIndex !== -1) {
                        let abBraceCount = 0;
                        let abEndIndex = -1;
                        for (let i = appBarIndex + 14; i < scaffoldContent.length; i++) {
                            if (scaffoldContent[i] === '(') abBraceCount++;
                            if (scaffoldContent[i] === ')') {
                                abBraceCount--;
                                if (abBraceCount === 0) {
                                    abEndIndex = i;
                                    break;
                                }
                            }
                        }
                        
                        if (abEndIndex !== -1) {
                            const appBarContent = scaffoldContent.substring(appBarIndex, abEndIndex + 1);
                            let titleMatch = appBarContent.match(/title:\s*(?:const\s*)?Text\(['"]([^'"]+)['"]/);
                            let title = titleMatch ? titleMatch[1] : 'Wonten Teka';
                            
                            let newAppBar = `appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const AppBrandTitle(section: '${title}'),
          centerTitle: true,
          iconTheme: const IconThemeData(color: AppColors.onSurface),
        )`;
                            scaffoldContent = scaffoldContent.substring(0, appBarIndex) + newAppBar + scaffoldContent.substring(abEndIndex + 1);
                        }
                    }

                    // Wrap in BrandPageBackground
                    scaffoldContent = scaffoldContent.replace('Scaffold(', 'BrandPageBackground(\n      child: Scaffold(\n        backgroundColor: Colors.transparent,');
                    scaffoldContent += ')';
                    
                    content = content.substring(0, index) + scaffoldContent + content.substring(endIndex + 1);
                    offset = index + scaffoldContent.length; // move offset past the new content
                } else {
                    offset = index + 9;
                }
            }
            fs.writeFileSync(file, content);
            success++;
        }
    } catch (e) {
        errors.push(file + ': ' + e.message);
    }
}
console.log(`Successfully updated ${success} files.`);
if (errors.length > 0) {
    console.log('Errors:', errors);
}
