/*
 * Copyright (c) 2023-2023. NESP Technology.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); 
 * you may not use this file except in compliance with the License. You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License 
 * for the specific language governing permissions and limitations under the License.
 *
 */
extension NullableObjectExtension<T extends Object> on T? {
  T or(T other) => this == null ? other : this!;

  R? castNullable<R>() => this == null ? null : this as R;

  R? tryCast<R>() => this is R ? this as R : null;

  bool isNull() => this == null;
}

extension ObjectExtension<T extends Object> on T {
  R cast<R>() => this as R;
}
