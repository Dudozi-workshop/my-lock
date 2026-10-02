import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../lock_engine/models.dart';
import '../../lock_engine/shape_spec/shape_spec.dart';

Uint8List seaTurtleUnderbellyNeutralRuntimeBytes() => base64Decode(_neutralWebp);

class SeaTurtleUnderbellyRuntimeQaScreen extends StatelessWidget {
  const SeaTurtleUnderbellyRuntimeQaScreen({super.key});

  static const _tones = <ShapeTone>[
    ShapeTone.pink,
    ShapeTone.blue,
    ShapeTone.yellow,
  ];

  @override
  Widget build(BuildContext context) {
    final neutralBytes = base64Decode(_neutralWebp);
    return Scaffold(
      appBar: AppBar(title: const Text('Sea Turtle · Underbelly Runtime QA')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'underbelly · simplified material v2 runtime check',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              'Neutral runtime source + ShapeTone color remap · '
              'Geometry FINAL_v4_cleanup / Outline v1 / Shadow v1 / '
              'Highlight v2 / Base-Albedo v2 fixed · no ImageGen',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final tone in _tones)
                  _ToneQaCard(tone: tone, neutralBytes: neutralBytes),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Review: 58 px belly-plane readability, broad highlight/shadow '
              'balance, outline continuity, alpha edge, and palette dominance. '
              'Pattern/Detail is intentionally not a production layer.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToneQaCard extends StatelessWidget {
  const _ToneQaCard({required this.tone, required this.neutralBytes});

  final ShapeTone tone;
  final Uint8List neutralBytes;

  @override
  Widget build(BuildContext context) {
    final color = baseColorForTone(tone);
    return SizedBox(
      width: 260,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${tone.name}  #${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _RuntimeSample(bytes: neutralBytes, color: color, size: 58, dark: false),
                  const SizedBox(width: 10),
                  _RuntimeSample(bytes: neutralBytes, color: color, size: 58, dark: true),
                ],
              ),
              const SizedBox(height: 8),
              const Text('58 px · light / dark'),
              const SizedBox(height: 12),
              Center(
                child: _RuntimeSample(
                  bytes: neutralBytes,
                  color: color,
                  size: 96,
                  dark: false,
                ),
              ),
              const Center(child: Text('96 px inspection')),
              const SizedBox(height: 12),
              Center(
                child: _RuntimeSample(
                  bytes: neutralBytes,
                  color: color,
                  size: 160,
                  dark: true,
                ),
              ),
              const Center(child: Text('160 px reference scale')),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuntimeSample extends StatelessWidget {
  const _RuntimeSample({
    required this.bytes,
    required this.color,
    required this.size,
    required this.dark,
  });

  final Uint8List bytes;
  final Color color;
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 20,
      height: size + 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF171A20) : const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.color),
        child: Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

const _neutralWebp =
    'UklGRqgFAABXRUJQVlA4TJsFAAAvX8AXEBXJzbZ9fZV/T8cyzOA6gLtL6+7u7u7uHHd3+3vs73HPdf3w6teft0p56mzxnwuZgBEooaPWjgmyRmCIjJBCcm3tjaR8Z7qqZX/pN5JqvN1il6zoJIiHQzzkwJpoxnsLW5Jk09ZcPVrfe873XL363qPNtZexZ21e22aEXNm2TduqjWfbRmQbP2Ajs22GTm1k9nuZbWe27TXX7GcocNtG6fiY7w/on4yKADlBL78MyEA9EUBStIGcoJNexmq2ApBSi8v7UYmuxY0U+HjUw+WqAwCAADKbSmQwEz/N9FyIwMmKjfRweo6ny3GP5LHZwaPzzls/DesAA1Q6BJAygHTT6mm5lqSiXlhyQhG08vpjfP5MPt989uV8qcCiPECwmg3kCDqpDfJ3NSsUoZfbNNXA6vl5fiOh+yqVr5p/oVBZ1B/H5HQqglNFXPUs7IoZBLIqACANAPkMRS7GvE51vhLPT3eylq5MWrEFK1f/faH5Fwm1CLx8wX+yYr5HzWaqN4teEbi62j2tgfp/9eTG/7jpwiqfO/l7UBPIMYCEGr78CzJg3utf7wvu4nhpLP6JZKWQkZDQpITmzqhgNkpORlFvZCbzW5v0a+VD7TNvhWLvqMRsxXby9eHRYPeiH9uNgS/0NEYACTDkabrJenxOuhhPTnWoVDsz76nGPeTMyj7oxUWLrALkFF9rqWosEk5C1B+H5NSIwIm39PvVg95aZoFSNFW6jNUsD+BqOT6vt6zQPBLrrhJHcZiE+HPhFqGrYszKDSFfEgxIyHsPu8r+ElixHD08v38w/OVYija9nJ5KmV2AYpjzCL2UdSvHkoam7ZgO4bBsEFSiVo/GiC87fKTwp5xAzAlGJBDRI64MBI1CialuCY4sOt1rDqRBDeVwFA/bUysqh5H/7UtCl3JcVBb80eMljc4CkwVmVVhF48sWf3YEoiMQfbQKGkElkdS/WxKuYQAlUbSBfAW6KS1gAEmeAZS44M9Op1apAsT+W0W7lymGpBhM0ISgGkFVii4Ms3KsIvCRRmOBSUgweIuva/6xlV25uXPY49WMqWEwgFLHw9UhxRKpY+SOJTR3D1BagNJi3C3GZTHulqIo4bvbKIpofFnjJYOXnAdjGWLOSitMVZbsmnG8VZ8e5zOwaetpWT0ZMyyUPEYm9sCkZYSzR0g9RmoJkiXIjeBRjq4cXQRmlVhF4yODW0UMhdoJUAKxr7Xbw0nMb0iBly8JJZkY/zLV7vL67Ex3kfK0SPwYObuMQu92EHuWEEkTHJbithSPERSlqMLRWOIyjlY17/3ZhZjzSk5c0hJc793eH8T8hPxVgRwVCTlgydvPoOvz0bm6auS2SPIYqm8ngLfYeImNl8wFzhCZInGGqBl/DBYYLDFZY7B2f3bmL0SWxJJ7eq97tz+xcn+7IgD72w867viEh79Op6ezFU9c+6g9WrmYSNZIfZoUeoVYj5DQJ9SEyl2uDKcw3ML4pKhAFYE0WDQLxpjTirlUrh69FcdoW/duv1/z2WZV0EH/bYABFF/78tvh9vvVkvL5+FTVXAXOWXm8ksdLiUmKz8I54sYRDXxhga/UWCPRqTyqLFyryvSigyFK4cjk3hmI3z/8IOwMLnEHh9ubDoKZzYsqBYKxhIY7XgCAoTczTdc/f408+XK79ubb5aWnL2cfa19PxL7X8nx4KVtO6qSlOSUlcHmilBql1CSlJymdhAylioRMapXqM3G9eptNFtArbtPxkmQzBRsAGEDFEffQZunt/6A9V18LT119bLp6/XHy/uXbrSc3r6/Kbh++VF3e/666vv9e+XzxrOnj/FTny+XGElzO6MBXPcq+1BWAvGDjTWIAJRlApcHni7UG3a1UYwDF3viS3n3FKenma6GQf+t/IujlhTRopWx2xZ9ums2iHzQCAA==';
